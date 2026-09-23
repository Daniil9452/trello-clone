export const COLORS = [
  { id: "#0079bf", name: "Синий" },
  { id: "#519839", name: "Зелёный" },
  { id: "#d29034", name: "Оранжевый" },
  { id: "#b04632", name: "Красный" },
  { id: "#89609e", name: "Фиолетовый" }
];

const FIELD_LABELS = {
  first_name: "Имя",
  last_name: "Фамилия",
  email: "Почта",
  password: "Пароль",
  name: "Название",
  description: "Описание",
  color: "Цвет"
};

export function errorText(error) {
  if (!error) return "";
  if (error.details && typeof error.details === "object") {
    return Object.entries(error.details)
      .map(([field, messages]) => {
        const label = FIELD_LABELS[field] || field;
        return `${label}: ${[].concat(messages).join(", ")}`;
      })
      .join(". ");
  }
  return error.message || "Не удалось выполнить запрос";
}

export function initials(person) {
  const first = (person.first_name || "").trim().charAt(0);
  const last = (person.last_name || "").trim().charAt(0);
  return `${first}${last}`.toUpperCase() || "•";
}

export function fullName(person) {
  return [person.first_name, person.last_name].filter(Boolean).join(" ");
}
