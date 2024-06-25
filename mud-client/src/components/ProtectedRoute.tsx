// src/components/ProtectedRoute.tsx
import React from 'react';
import { Route, Navigate, RouteProps } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';



const ProtectedRoute = () => {
  const { user } = useAuth();

  return (
  <div></div>
  );
};

export default ProtectedRoute;
