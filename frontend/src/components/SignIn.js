import { useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, Navigate } from "react-router-dom";
import { clearError, login } from "../features/sessionSlice";

export default function SignIn() {
  const dispatch = useDispatch();
  const status = useSelector((state) => state.session.status);
  const error = useSelector((state) => state.session.error);
  const [email, setEmail] = useState("demo@example.com");
  const [password, setPassword] = useState("parol12345");

  if (status === "authenticated") return <Navigate to="/" replace />;

  function onSubmit(event) {
    event.preventDefault();
    dispatch(login({ email, password }));
  }

  return (
    <main className="auth-screen">
      <form className="auth-card" onSubmit={onSubmit}>
        <p className="eyebrow">Канбан для учебной практики</p>
        <h1>Вход в Trello Clone</h1>
        <label>
          Почта
          <input
            type="email"
            autoComplete="username"
            value={email}
            onChange={(event) => {
              dispatch(clearError());
              setEmail(event.target.value);
            }}
            required
          />
        </label>
        <label>
          Пароль
          <input
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(event) => {
              dispatch(clearError());
              setPassword(event.target.value);
            }}
            required
          />
        </label>
        {error ? <p className="form-error">{error}</p> : null}
        <button className="primary-button" type="submit" disabled={status === "loading"}>
          Войти
        </button>
        <p className="auth-switch">
          Нет аккаунта? <Link to="/sign-up">Зарегистрироваться</Link>
        </p>
        <p className="hint">
          Тестовый доступ: demo@example.com и maria@example.com, пароль parol12345
        </p>
      </form>
    </main>
  );
}
