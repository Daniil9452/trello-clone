import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { api } from "../api";

export const fetchBoards = createAsyncThunk("boards/fetch", async (_, { rejectWithValue }) => {
  try {
    return await api("/api/boards");
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const createBoard = createAsyncThunk("boards/create", async (payload, { rejectWithValue }) => {
  try {
    return await api("/api/boards", { method: "POST", body: { board: payload } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

const boardsSlice = createSlice({
  name: "boards",
  initialState: {
    owned: [],
    shared: [],
    status: "idle",
    error: null
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchBoards.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(fetchBoards.fulfilled, (state, action) => {
        state.status = "ready";
        state.owned = action.payload.owned;
        state.shared = action.payload.shared;
      })
      .addCase(fetchBoards.rejected, (state, action) => {
        state.status = "ready";
        state.error = action.payload;
      })
      .addCase(createBoard.fulfilled, (state, action) => {
        state.owned.push(action.payload.board);
        state.error = null;
      })
      .addCase(createBoard.rejected, (state, action) => {
        state.error = action.payload;
      });
  }
});

export default boardsSlice.reducer;
