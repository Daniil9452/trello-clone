import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { api } from "../api";

export const fetchBoard = createAsyncThunk("board/fetch", async (id, { rejectWithValue }) => {
  try {
    return await api(`/api/boards/${id}`);
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const saveBoard = createAsyncThunk("board/save", async ({ id, changes }, { rejectWithValue }) => {
  try {
    return await api(`/api/boards/${id}`, { method: "PATCH", body: { board: changes } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const deleteBoard = createAsyncThunk("board/delete", async (id, { rejectWithValue }) => {
  try {
    return await api(`/api/boards/${id}`, { method: "DELETE" });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const addMember = createAsyncThunk("board/addMember", async ({ id, email }, { rejectWithValue }) => {
  try {
    return await api(`/api/boards/${id}/members`, { method: "POST", body: { email } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const removeMember = createAsyncThunk(
  "board/removeMember",
  async ({ boardId, userId }, { rejectWithValue }) => {
    try {
      return await api(`/api/boards/${boardId}/members/${userId}`, { method: "DELETE" });
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const createList = createAsyncThunk("board/createList", async ({ boardId, name }, { rejectWithValue }) => {
  try {
    return await api(`/api/boards/${boardId}/lists`, { method: "POST", body: { list: { name } } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const updateList = createAsyncThunk("board/updateList", async ({ id, name }, { rejectWithValue }) => {
  try {
    return await api(`/api/lists/${id}`, { method: "PATCH", body: { list: { name } } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const deleteList = createAsyncThunk("board/deleteList", async (id, { rejectWithValue }) => {
  try {
    return await api(`/api/lists/${id}`, { method: "DELETE" });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const createCard = createAsyncThunk("board/createCard", async ({ listId, name }, { rejectWithValue }) => {
  try {
    return await api(`/api/lists/${listId}/cards`, { method: "POST", body: { card: { name } } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const updateCard = createAsyncThunk("board/updateCard", async ({ id, changes }, { rejectWithValue }) => {
  try {
    return await api(`/api/cards/${id}`, { method: "PATCH", body: { card: changes } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const deleteCard = createAsyncThunk("board/deleteCard", async (id, { rejectWithValue }) => {
  try {
    return await api(`/api/cards/${id}`, { method: "DELETE" });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const moveCard = createAsyncThunk(
  "board/moveCard",
  async ({ id, listId, position }, { rejectWithValue }) => {
    try {
      return await api(`/api/cards/${id}/move`, {
        method: "POST",
        body: { list_id: listId, position }
      });
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

function sortLists(lists) {
  return [...lists].sort((a, b) => a.position - b.position || a.id - b.id);
}

function upsertList(state, incoming) {
  const lists = state.data.lists;
  const index = lists.findIndex((list) => list.id === incoming.id);
  if (index === -1) {
    lists.push({ ...incoming, cards: incoming.cards || [] });
  } else {
    const current = lists[index];
    lists[index] = {
      ...current,
      ...incoming,
      cards: incoming.cards || current.cards
    };
  }
  state.data.lists = sortLists(lists);
}

function upsertCard(state, card) {
  const list = state.data.lists.find((item) => item.id === card.list_id);
  if (!list) return;
  const index = list.cards.findIndex((item) => item.id === card.id);
  if (index === -1) list.cards.push(card);
  else list.cards[index] = card;
  list.cards.sort((a, b) => a.position - b.position || a.id - b.id);
}

const eventReducers = {
  "list:created": (state, data) => upsertList(state, data.list),
  "list:updated": (state, data) => upsertList(state, data.list),
  "list:deleted": (state, data) => {
    state.data.lists = state.data.lists.filter((list) => list.id !== data.id);
  },
  "card:created": (state, data) => upsertCard(state, data.card),
  "card:updated": (state, data) => upsertCard(state, data.card),
  "card:deleted": (state, data) => {
    const list = state.data.lists.find((item) => item.id === data.list_id);
    if (list) list.cards = list.cards.filter((card) => card.id !== data.id);
  },
  "card:moved": (state, data) => {
    data.lists.forEach((incoming) => {
      const list = state.data.lists.find((item) => item.id === incoming.id);
      if (list) list.cards = incoming.cards;
    });
  },
  "member:added": (state, data) => {
    const exists = state.data.members.some((member) => member.id === data.member.id);
    if (!exists && data.member.id !== state.data.owner.id) state.data.members.push(data.member);
  },
  "member:removed": (state, data) => {
    state.data.members = state.data.members.filter((member) => member.id !== data.user_id);
  },
  "board:updated": (state, data) => {
    state.data.name = data.board.name;
    state.data.color = data.board.color;
  }
};

const boardSlice = createSlice({
  name: "board",
  initialState: {
    data: null,
    status: "idle",
    error: null,
    actionError: null,
    online: [],
    connection: "offline",
    deleted: false
  },
  reducers: {
    resetBoard(state) {
      state.data = null;
      state.status = "idle";
      state.error = null;
      state.actionError = null;
      state.online = [];
      state.connection = "offline";
      state.deleted = false;
    },
    setOnline(state, action) {
      state.online = action.payload;
    },
    setConnection(state, action) {
      state.connection = action.payload;
    },
    applyEvent(state, action) {
      const { event, data } = action.payload;
      if (event === "board:deleted") {
        state.deleted = true;
        return;
      }
      const reducer = eventReducers[event];
      if (reducer && state.data) reducer(state, data);
    },
    clearActionError(state) {
      state.actionError = null;
    }
  },
  extraReducers: (builder) => {
    const fail = (state, action) => {
      state.actionError = action.payload;
    };

    builder
      .addCase(fetchBoard.pending, (state) => {
        state.status = "loading";
        state.error = null;
        state.deleted = false;
      })
      .addCase(fetchBoard.fulfilled, (state, action) => {
        state.status = "ready";
        state.data = action.payload.board;
      })
      .addCase(fetchBoard.rejected, (state, action) => {
        state.status = "ready";
        state.data = null;
        state.error = action.payload;
      })
      .addCase(saveBoard.fulfilled, (state, action) => {
        if (!state.data) return;
        state.data.name = action.payload.board.name;
        state.data.color = action.payload.board.color;
        state.actionError = null;
      })
      .addCase(deleteBoard.fulfilled, (state) => {
        state.deleted = true;
      })
      .addCase(addMember.fulfilled, (state, action) => {
        eventReducers["member:added"](state, action.payload);
        state.actionError = null;
      })
      .addCase(removeMember.fulfilled, (state, action) => {
        eventReducers["member:removed"](state, action.payload);
        state.actionError = null;
      })
      .addCase(createList.fulfilled, (state, action) => {
        eventReducers["list:created"](state, action.payload);
        state.actionError = null;
      })
      .addCase(updateList.fulfilled, (state, action) => {
        eventReducers["list:updated"](state, action.payload);
        state.actionError = null;
      })
      .addCase(deleteList.fulfilled, (state, action) => {
        eventReducers["list:deleted"](state, action.payload);
        state.actionError = null;
      })
      .addCase(createCard.fulfilled, (state, action) => {
        eventReducers["card:created"](state, action.payload);
        state.actionError = null;
      })
      .addCase(updateCard.fulfilled, (state, action) => {
        eventReducers["card:updated"](state, action.payload);
        state.actionError = null;
      })
      .addCase(deleteCard.fulfilled, (state, action) => {
        eventReducers["card:deleted"](state, action.payload);
        state.actionError = null;
      })
      .addCase(moveCard.fulfilled, (state, action) => {
        eventReducers["card:moved"](state, action.payload);
        state.actionError = null;
      })
      .addCase(saveBoard.rejected, fail)
      .addCase(deleteBoard.rejected, fail)
      .addCase(addMember.rejected, fail)
      .addCase(removeMember.rejected, fail)
      .addCase(createList.rejected, fail)
      .addCase(updateList.rejected, fail)
      .addCase(deleteList.rejected, fail)
      .addCase(createCard.rejected, fail)
      .addCase(updateCard.rejected, fail)
      .addCase(deleteCard.rejected, fail)
      .addCase(moveCard.rejected, fail);
  }
});

export const { resetBoard, setOnline, setConnection, applyEvent, clearActionError } = boardSlice.actions;
export default boardSlice.reducer;
