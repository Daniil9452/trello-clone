import { useEffect, useRef, useState } from "react";
import { useDispatch } from "react-redux";
import { createCard, deleteList, moveCard, updateList } from "../features/boardSlice";

export default function ListColumn({ list, onOpenCard }) {
  const dispatch = useDispatch();
  const [name, setName] = useState(list.name);
  const [cardName, setCardName] = useState("");
  const dragging = useRef(false);

  useEffect(() => {
    setName(list.name);
  }, [list.name]);

  function saveName() {
    const next = name.trim();
    if (next && next !== list.name) dispatch(updateList({ id: list.id, name: next }));
    else setName(list.name);
  }

  function onAddCard(event) {
    event.preventDefault();
    dispatch(createCard({ listId: list.id, name: cardName })).then((result) => {
      if (createCard.fulfilled.match(result)) setCardName("");
    });
  }

  function onDrop(event, position) {
    event.preventDefault();
    event.stopPropagation();
    const cardId = Number(event.dataTransfer.getData("text/card-id"));
    if (!cardId) return;
    dispatch(moveCard({ id: cardId, listId: list.id, position }));
  }

  return (
    <section className="list-column" onDragOver={(event) => event.preventDefault()} onDrop={(event) => onDrop(event, list.cards.length + 1)}>
      <header>
        <input
          value={name}
          aria-label="Название списка"
          onChange={(event) => setName(event.target.value)}
          onBlur={saveName}
          onKeyDown={(event) => {
            if (event.key === "Enter") event.currentTarget.blur();
          }}
        />
        <button
          type="button"
          className="icon-button"
          aria-label="Удалить список"
          onClick={() => {
            if (window.confirm("Удалить список и его карточки?")) dispatch(deleteList(list.id));
          }}
        >
          ×
        </button>
      </header>
      <div className="cards">
        {list.cards.map((card, index) => (
          <div
            key={card.id}
            role="button"
            tabIndex={0}
            className="card"
            draggable
            onDragStart={(event) => {
              dragging.current = true;
              event.dataTransfer.setData("text/card-id", String(card.id));
              event.dataTransfer.effectAllowed = "move";
            }}
            onDragEnd={() => {
              setTimeout(() => {
                dragging.current = false;
              }, 0);
            }}
            onDragOver={(event) => event.preventDefault()}
            onDrop={(event) => onDrop(event, index + 1)}
            onClick={() => {
              if (dragging.current) return;
              onOpenCard(card);
            }}
            onKeyDown={(event) => {
              if (event.key === "Enter") onOpenCard(card);
            }}
          >
            <h3>{card.name}</h3>
            {card.description ? <p>{card.description}</p> : null}
          </div>
        ))}
      </div>
      <form className="add-card" onSubmit={onAddCard}>
        <input
          value={cardName}
          onChange={(event) => setCardName(event.target.value)}
          placeholder="Новая карточка"
          aria-label="Название карточки"
        />
        <button type="submit" disabled={!cardName.trim()}>
          Добавить
        </button>
      </form>
    </section>
  );
}
