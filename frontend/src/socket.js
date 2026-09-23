import { Presence, Socket } from "phoenix";

const EVENTS = [
  "list:created",
  "list:updated",
  "list:deleted",
  "card:created",
  "card:updated",
  "card:deleted",
  "card:moved",
  "member:added",
  "member:removed",
  "board:updated",
  "board:deleted"
];

export function joinBoard(boardId, token, handlers) {
  const socket = new Socket("/socket", { params: { token } });
  socket.connect();

  const channel = socket.channel(`board:${boardId}`, {});
  let presence = {};

  const emitPresence = () => {
    const users = Presence.list(presence, (_id, { metas }) => metas[0]);
    handlers.onPresence(users);
  };

  channel.on("presence_state", (state) => {
    presence = Presence.syncState(presence, state);
    emitPresence();
  });

  channel.on("presence_diff", (diff) => {
    presence = Presence.syncDiff(presence, diff);
    emitPresence();
  });

  EVENTS.forEach((event) => {
    channel.on(event, (payload) => handlers.onEvent(event, payload));
  });

  channel
    .join()
    .receive("ok", () => handlers.onStatus("online"))
    .receive("error", () => handlers.onStatus("error"));

  channel.onError(() => handlers.onStatus("offline"));

  return () => {
    channel.leave();
    socket.disconnect();
  };
}
