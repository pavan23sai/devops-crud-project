
import http from 'k6/http';
import { check, sleep } from 'k6';

// Configure the load test: 500 concurrent virtual users for 60 seconds.
const BASE_URL = __ENV.BASE_URL || 'http://127.0.0.1:61878';

export const options = {
  scenarios: {
    taskmanager_load: {
      executor: 'constant-vus',
      vus: 500,
      duration: '60s',
    },
  },

  // Define acceptable performance thresholds.
  thresholds: {
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<2000'],
  },
};

// This function runs repeatedly for every virtual user.
export default function () {

  // Send a GET request to retrieve tasks from the Kubernetes application.
    const response = http.get(BASE_URL + '/tasks');

  // Verify that the API responds successfully with JSON.
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response is JSON': (r) =>
      r.headers['Content-Type']?.includes('application/json'),
  });

  // Wait briefly before the next request.
  sleep(1);
}
