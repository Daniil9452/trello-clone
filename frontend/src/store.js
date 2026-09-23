import { configureStore } from "@reduxjs/toolkit";
import sessionReducer from "./features/sessionSlice";
import boardsReducer from "./features/boardsSlice";
import boardReducer from "./features/boardSlice";

export const store = configureStore({
  reducer: {
    session: sessionReducer,
    boards: boardsReducer,
    board: boardReducer
  }
});
