import React, { createContext, useContext, useEffect, useState } from "react";
import { getToken, removeToken } from "@/api/client";
import { useUserInfo } from "@/api/auth";
import type { User } from "@/types";

interface AuthContextValue {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  isLoading: true,
  isAuthenticated: false,
  logout: () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(!!getToken());
  const { data: user, isLoading, isError } = useUserInfo();

  useEffect(() => {
    if (isError) {
      setIsAuthenticated(false);
    } else if (user) {
      setIsAuthenticated(true);
    }
  }, [user, isError]);

  const logout = () => {
    removeToken();
    setIsAuthenticated(false);
    window.location.href = "/login";
  };

  return (
    <AuthContext.Provider
      value={{
        user: user ?? null,
        isLoading,
        isAuthenticated,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
