const axios = require("axios");
const { logger } = require("../utils/logger");
const { generateEncryptedApiRequestDetails } = require("./encryption.service");
const { client } = require("../config/client.config");

exports.call = async (method, path, body = {}) => {
  const { headers, encryptedBody } = generateEncryptedApiRequestDetails(
    client,
    method,
    body,
    path,
  );

  const url = `${path}`;
  const isGet = method.toUpperCase() === "GET";

  const requestConfig = {
    method,
    url,
    headers,
    timeout: 10000,
  };

  if (isGet) {
    requestConfig.params = encryptedBody; // query string
  } else {
    requestConfig.data = encryptedBody; // POST body
  }

  logger.debug("API_REQUEST", { method, url, headers, body, encryptedBody });

  try {
    const res = await axios(requestConfig);
    return {
      status: res.status,
      body: res.data,
    };
  } catch (err) {
    const status = err.response?.status;
    const data = err.response?.data;

    logger.error("API_ERROR", {
      method,
      url,
      message: err.message,
      status,
      response: data,
    });

    return {
      status: status || "NETWORK_ERROR",
      body: data || { error: err.message },
    };
  }
};
