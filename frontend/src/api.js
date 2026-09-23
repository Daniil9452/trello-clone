import { errorText } from "./text";

export async function api(path, { method = "GET", body, token } = {}) {
  const headers = {
    Accept: "application/json",
    "Content-Type": "application/json"
  };
  const stored = token || localStorage.getItem("doski_token");
  if (stored) headers.Authorization = `Bearer ${stored}`;

  let response;
  try {
    response = await fetch(path, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    });
  } catch (_networkError) {
    const error = new Error("Нет соединения с сервером");
    error.status = 0;
    throw error;
  }

  const data = response.status === 204 ? null : await response.json().catch(() => ({}));
  if (!response.ok) {
    const error = new Error(data.error || "Ошибка запроса");
    error.status = response.status;
    error.details = data.errors;
    error.message = errorText(error);
    throw error;
  }
  return data;
}
