const { Worker } = require("bullmq");
const { logger } = require("../utils/logger");
const connection = require("../config/redis.config");
const cucumberService = require("../services/cucumber.service");
const reportService = require("../services/report.service");

async function runCucumber(jobId, jobData) {
  const timestamp = Date.now();

  try {
    logger.info("CUCUMBER_START", { jobId });

    const jsonFile = await cucumberService.run(timestamp, {
      jobId,
      ...jobData,
    });

    logger.info("CUCUMBER_COMPLETED", { jobId, jsonFile });

    return { jsonFile, timestamp, error: null };
  } catch (err) {
    logger.error("CUCUMBER_FAILED", {
      jobId,
      error: err.message,
      stack: err.stack,
    });

    return { jsonFile: null, timestamp, error: err };
  }
}

const worker = new Worker(
  "api-test-runner",
  async (job) => {
    const jobId = job.id;

    try {
      logger.info("JOB_STARTED", { jobId, format: job.data.format });
      await job.updateProgress(10);

      const {
        jsonFile,
        error: cucumberError,
        timestamp,
      } = await runCucumber(jobId, job.data);

      await job.updateProgress(60);

      logger.info("REPORT_START", { jobId });

      const reportFile = await reportService.generate(
        job.data.format,
        timestamp,
      );

      await job.updateProgress(100);

      logger.info("JOB_COMPLETED", {
        jobId,
        reportFile,
        failed: Boolean(cucumberError),
      });

      return { reportFile, failed: Boolean(cucumberError) };
    } catch (err) {
      logger.error("JOB_FAILED", {
        jobId,
        error: err.message,
        stack: err.stack,
      });
      throw err;
    }
  },
  { connection },
);

worker.on("completed", (job, result) => {
  logger.info("WORKER_JOB_SUCCESS", {
    jobId: job.id,
    reportFile: result?.reportFile,
    failed: result?.failed,
  });
});

worker.on("failed", (job, err) => {
  logger.error("WORKER_JOB_FAILED", {
    jobId: job?.id,
    error: err.message,
  });
});

worker.on("progress", (job, progress) => {
  logger.info("WORKER_JOB_PROGRESS", { jobId: job.id, progress });
});

module.exports = worker;
