import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { api } from "../api";

const storedUser = (() => {
  try {
    return JSON.parse(localStorage.getItem("doski_user") || "null");
  } catch (_error) {
    return null;
  }
})();

export const login = createAsyncThunk("session/login", async (payload, { rejectWithValue }) => {
  try {
    return await api("/api/sessions", { method: "POST", body: { session: payload } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const register = createAsyncThunk("session/register", async (payload, { rejectWithValue }) => {
  try {
    return await api("/api/registrations", { method: "POST", body: { user: payload } });
  } catch (error) {
    return rejectWithValue(error.message);
  }
});

export const restoreSession = createAsyncThunk("session/restore", async (_, { rejectWithValue }) => {
  const token = localStorage.getItem("doski_token");
  if (!token) return rejectWithValue(null);
  try {
    const data = await api("/api/me", { token });
    return { token, user: data.user };
  } catch (error) {
    return rejectWithValue(error.status === 401 ? null : error.message);
  }
});

function persist(token, user) {
  localStorage.setItem("doski_token", token);
  localStorage.setItem("doski_user", JSON.stringify(user));
}

function clearStorage() {
  localStorage.removeItem("doski_token");
  localStorage.removeItem("doski_user");
}

const sessionSlice = createSlice({
  name: "session",
  initialState: {
    token: localStorage.getItem("doski_token"),
    user: storedUser,
    status: localStorage.getItem("doski_token") ? "loading" : "anonymous",
    error: null
  },
  reducers: {
    logout(state) {
      state.token = null;
      state.user = null;
      state.status = "anonymous";
      state.error = null;
      clearStorage();
    },
    clearError(state) {
      state.error = null;
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(register.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.token = action.payload.token;
        state.user = action.payload.user;
        state.status = "authenticated";
        persist(action.payload.token, action.payload.user);
      })
      .addCase(register.fulfilled, (state, action) => {
        state.token = action.payload.token;
        state.user = action.payload.user;
        state.status = "authenticated";
        persist(action.payload.token, action.payload.user);
      })
      .addCase(login.rejected, (state, action) => {
        state.status = "anonymous";
        state.error = action.payload || "Не удалось войти";
      })
      .addCase(register.rejected, (state, action) => {
        state.status = "anonymous";
        state.error = action.payload || "Не удалось зарегистрироваться";
      })
      .addCase(restoreSession.fulfilled, (state, action) => {
        state.token = action.payload.token;
        state.user = action.payload.user;
        state.status = "authenticated";
        persist(action.payload.token, action.payload.user);
      })
      .addCase(restoreSession.rejected, (state) => {
        state.token = null;
        state.user = null;
        state.status = "anonymous";
        clearStorage();
      });
  }
});

export const { logout, clearError } = sessionSlice.actions;
export default sessionSlice.reducer;
