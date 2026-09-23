import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate, useParams } from "react-router-dom";
import Header from "./Header";
import ListColumn from "./ListColumn";
import CardModal from "./CardModal";
import { joinBoard } from "../socket";
import {
  addMember,
  applyEvent,
  clearActionError,
  createList,
  deleteBoard,
  fetchBoard,
  removeMember,
  resetBoard,
  saveBoard,
  setConnection,
  setOnline
} from "../features/boardSlice";
import { COLORS, fullName, initials } from "../text";

export default function BoardView() {
  const { id } = useParams();
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const token = useSelector((state) => state.session.token);
  const currentUser = useSelector((state) => state.session.user);
  const boardState = useSelector((state) => state.board);
  const { data, status, error, actionError, online, connection, deleted } = boardState;
  const [listName, setListName] = useState("");
  const [email, setEmail] = useState("");
  const [openedCard, setOpenedCard] = useState(null);

  useEffect(() => {
    dispatch(resetBoard());
    dispatch(fetchBoard(id));
  }, [dispatch, id]);

  useEffect(() => {
    if (!token) return undefined;
    return joinBoard(id, token, {
      onPresence: (users) => dispatch(setOnline(users)),
      onStatus: (value) => dispatch(setConnection(value)),
      onEvent: (event, payload) => dispatch(applyEvent({ event, data: payload }))
    });
  }, [dispatch, id, token]);

  useEffect(() => {
    if (deleted) navigate("/");
  }, [deleted, navigate]);

  useEffect(() => {
    if (!openedCard || !data) return;
    const fresh = data.lists.flatMap((list) => list.cards).find((card) => card.id === openedCard.id);
    if (!fresh) setOpenedCard(null);
    else if (fresh.name !== openedCard.name || fresh.description !== openedCard.description) {
      setOpenedCard(fresh);
    }
  }, [data, openedCard]);

  if (status === "loading" && !data) return <p className="screen-message">Загрузка доски…</p>;
  if (error) return <p className="screen-message">{error}</p>;
  if (!data) return null;

  const isOwner = currentUser && data.owner.id === currentUser.id;
  const connectionLabel = { online: "на связи", offline: "нет соединения", error: "нет доступа к каналу" }[
    connection
  ];

  async function onRename(event) {
    event.preventDefault();
    dispatch(saveBoard({ id: data.id, changes: { name: event.target.boardName.value } }));
  }

  async function onInvite(event) {
    event.preventDefault();
    const result = await dispatch(addMember({ id: data.id, email }));
    if (addMember.fulfilled.match(result)) setEmail("");
  }

  async function onDeleteBoard() {
    if (window.confirm("Удалить доску вместе со списками и карточками?")) {
      dispatch(deleteBoard(data.id));
    }
  }

  async function onAddList(event) {
    event.preventDefault();
    const result = await dispatch(createList({ boardId: data.id, name: listName }));
    if (createList.fulfilled.match(result)) setListName("");
  }

  return (
    <div className="board-screen" style={{ background: data.color }}>
      <Header boardName={data.name} tone="board" />
      <div className="board-toolbar">
        <form className="rename-form" onSubmit={onRename}>
          <input name="boardName" key={data.name} defaultValue={data.name} aria-label="Название доски" />
          <button type="submit">Сохранить</button>
        </form>
        <div className="presence" title="Кто сейчас смотрит доску">
          <span className={`dot dot-${connection}`} />
          <span>{connectionLabel}</span>
          <div className="avatars">
            {online.map((person) => (
              <span key={person.id} className="avatar" title={fullName(person)}>
                {initials(person)}
              </span>
            ))}
          </div>
        </div>
      </div>
      {actionError ? (
        <p className="banner" role="alert">
          {actionError}
          <button type="button" onClick={() => dispatch(clearActionError())}>
            Скрыть
          </button>
        </p>
      ) : null}
      <section className="board-bar">
        <div className="member-row">
          <div className="person">
            <span className="member-label">Владелец</span>
            <strong>{fullName(data.owner)}</strong>
          </div>
          {data.members.map((member) => (
            <div key={member.id} className="member-chip">
              <span>{fullName(member)}</span>
              {isOwner ? (
                <button
                  type="button"
                  onClick={() => dispatch(removeMember({ boardId: data.id, userId: member.id }))}
                >
                  Убрать
                </button>
              ) : null}
            </div>
          ))}
          <form className="invite-form" onSubmit={onInvite}>
            <input
              type="email"
              placeholder="Почта участника"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
            <button type="submit">Пригласить</button>
          </form>
        </div>
        <div className="board-actions">
          <div className="color-row compact">
          {COLORS.map((item) => (
            <button
              key={item.id}
              type="button"
              className={item.id === data.color ? "swatch-button selected" : "swatch-button"}
              style={{ background: item.id }}
              aria-label={item.name}
              onClick={() => dispatch(saveBoard({ id: data.id, changes: { name: data.name, color: item.id } }))}
            />
          ))}
        </div>
          {isOwner ? (
            <button className="danger-button" type="button" onClick={onDeleteBoard}>
              Удалить доску
            </button>
          ) : null}
        </div>
      </section>
      <div className="lists">
        {data.lists.map((list) => (
          <ListColumn key={list.id} list={list} onOpenCard={setOpenedCard} />
        ))}
        <form className="add-list" onSubmit={onAddList}>
          <input
            value={listName}
            onChange={(event) => setListName(event.target.value)}
            placeholder="Название списка"
            aria-label="Название списка"
            required
          />
          <button type="submit">Добавить список</button>
        </form>
      </div>
      {openedCard ? <CardModal card={openedCard} onClose={() => setOpenedCard(null)} /> : null}
    </div>
  );
}
