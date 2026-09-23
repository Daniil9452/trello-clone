import { useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate } from "react-router-dom";
import { clearError, register } from "../features/sessionSlice";

const EMPTY = { first_name: "", last_name: "", email: "", password: "" };

export default function SignUp() {
  const dispatch = useDispatch();
  const status = useSelector((state) => state.session.status);
  const error = useSelector((state) => state.session.error);
  const [form, setForm] = useState(EMPTY);

  if (status === "authenticated") return <Navigate to="/" replace />;

  function update(field, value) {
    dispatch(clearError());
    setForm((current) => ({ ...current, [field]: value }));
  }

  function onSubmit(event) {
    event.preventDefault();
    dispatch(register(form));
  }

  return (
    <main className="auth-screen">
      <form className="auth-card" onSubmit={onSubmit}>
        <p className="eyebrow">Новый аккаунт</p>
        <h1>Регистрация</h1>
        <label>
          Имя
          <input value={form.first_name} onChange={(event) => update("first_name", event.target.value)} required />
        </label>
        <label>
          Фамилия
          <input value={form.last_name} onChange={(event) => update("last_name", event.target.value)} required />
        </label>
        <label>
          Почта
          <input
            type="email"
            autoComplete="username"
            value={form.email}
            onChange={(event) => update("email", event.target.value)}
            required
          />
        </label>
        <label>
          Пароль
          <input
            type="password"
            autoComplete="new-password"
            minLength={8}
            value={form.password}
            onChange={(event) => update("password", event.target.value)}
            required
          />
        </label>
        {error ? <p className="form-error">{error}</p> : null}
        <button className="primary-button" type="submit" disabled={status === "loading"}>
          Создать аккаунт
        </button>
        <p className="auth-switch">
          Уже есть аккаунт? <Link to="/sign-in">Войти</Link>
        </p>
      </form>
    </main>
  );
}
