import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link } from "react-router-dom";
import Header from "./Header";
import { createBoard, fetchBoards } from "../features/boardsSlice";
import { COLORS, fullName } from "../text";

function BoardTile({ board, shared }) {
  return (
    <Link className="board-tile" to={`/boards/${board.id}`} style={{ background: board.color }}>
      <strong>{board.name}</strong>
      <span>{shared ? fullName(board.owner) : "Моя доска"}</span>
    </Link>
  );
}

export default function Home() {
  const dispatch = useDispatch();
  const { owned, shared, status, error } = useSelector((state) => state.boards);
  const [name, setName] = useState("");
  const [color, setColor] = useState(COLORS[0].id);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    dispatch(fetchBoards());
  }, [dispatch]);

  async function onCreate(event) {
    event.preventDefault();
    const result = await dispatch(createBoard({ name, color }));
    if (createBoard.fulfilled.match(result)) {
      setName("");
      setOpen(false);
    }
  }

  return (
    <div className="home">
      <Header framed />
      <main className="home-main page-frame">
        <section className="home-section">
          <div className="section-head">
            <h1>Мои доски</h1>
            <button className="primary-button" type="button" onClick={() => setOpen((value) => !value)}>
              {open ? "Закрыть" : "Новая доска"}
            </button>
          </div>
          {open ? (
            <form className="new-board" onSubmit={onCreate}>
              <input
                value={name}
                onChange={(event) => setName(event.target.value)}
                placeholder="Название доски"
                aria-label="Название доски"
                required
                maxLength={120}
              />
              <div className="color-row" role="radiogroup" aria-label="Цвет доски">
                {COLORS.map((item) => (
                  <label key={item.id} className={item.id === color ? "swatch selected" : "swatch"}>
                    <input
                      type="radio"
                      name="color"
                      value={item.id}
                      checked={item.id === color}
                      onChange={() => setColor(item.id)}
                    />
                    <span style={{ background: item.id }} title={item.name} />
                  </label>
                ))}
              </div>
              <button className="primary-button" type="submit">
                Создать
              </button>
            </form>
          ) : null}
          {error ? <p className="form-error">{error}</p> : null}
          {status === "loading" ? <p>Загрузка досок…</p> : null}
          <div className="tile-grid">
            {owned.map((board) => (
              <BoardTile key={board.id} board={board} />
            ))}
            {status === "ready" && owned.length === 0 ? <p className="empty">Своих досок пока нет.</p> : null}
          </div>
        </section>
        <section className="home-section">
          <div className="section-head">
            <h1>Общие доски</h1>
          </div>
          <div className="tile-grid">
            {shared.map((board) => (
              <BoardTile key={board.id} board={board} shared />
            ))}
            {status === "ready" && shared.length === 0 ? (
              <p className="empty">Вас ещё не приглашали на чужие доски.</p>
            ) : null}
          </div>
        </section>
      </main>
    </div>
  );
}
