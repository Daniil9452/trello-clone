import { useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import { deleteCard, updateCard } from "../features/boardSlice";

export default function CardModal({ card, onClose }) {
  const dispatch = useDispatch();
  const [name, setName] = useState(card.name);
  const [description, setDescription] = useState(card.description || "");

  useEffect(() => {
    setName(card.name);
    setDescription(card.description || "");
  }, [card]);

  useEffect(() => {
    function onKey(event) {
      if (event.key === "Escape") onClose();
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  function save(event) {
    event.preventDefault();
    dispatch(updateCard({ id: card.id, changes: { name: name.trim(), description } }));
    onClose();
  }

  function remove() {
    if (window.confirm("Удалить карточку?")) {
      dispatch(deleteCard(card.id));
      onClose();
    }
  }

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <form className="modal" onClick={(event) => event.stopPropagation()} onSubmit={save}>
        <h2>Карточка</h2>
        <label>
          Название
          <input value={name} onChange={(event) => setName(event.target.value)} required maxLength={200} />
        </label>
        <label>
          Описание
          <textarea
            value={description}
            onChange={(event) => setDescription(event.target.value)}
            rows={5}
            maxLength={5000}
          />
        </label>
        <div className="modal-actions">
          <button className="danger-button" type="button" onClick={remove}>
            Удалить
          </button>
          <div>
            <button className="ghost-button" type="button" onClick={onClose}>
              Закрыть
            </button>
            <button className="primary-button" type="submit">
              Сохранить
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
