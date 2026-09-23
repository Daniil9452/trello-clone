import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { logout } from "../features/sessionSlice";
import { fullName } from "../text";

export default function Header({ boardName, tone = "default", framed = false }) {
  const user = useSelector((state) => state.session.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();

  function onLogout() {
    dispatch(logout());
    navigate("/sign-in");
  }

  const bar = (
    <>
      <div className="topbar-side">
        <Link className="brand" to="/">
          Trello Clone
        </Link>
        {boardName ? <span className="crumb">{boardName}</span> : null}
      </div>
      <div className="topbar-side">
        {user ? <span className="who">{fullName(user)}</span> : null}
        <button className="ghost-button" type="button" onClick={onLogout}>
          Выйти
        </button>
      </div>
    </>
  );

  return (
    <header className={`topbar topbar-${tone}${framed ? " topbar-framed" : ""}`}>
      {framed ? <div className="page-frame">{bar}</div> : bar}
    </header>
  );
}
