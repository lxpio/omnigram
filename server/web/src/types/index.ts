export interface Book {
  id: string;
  title: string;
  author: string;
  isbn: string;
  asin: string;
  cover_url: string;
  description: string;
  file_type: string;
  series: string;
  publisher: string;
  rating: number;
  tags: string;
  count_visit: number;
  count_download: number;
  ctime: number;
  utime: number;
  size: number;
}

export interface User {
  id: number;
  name: string;
  email: string;
  mobile: string;
  nick_name: string;
  avatar_url: string;
  role_id: number;
  locked: boolean;
  ctime: number;
  utime: number;
  atime: number;
}

export interface LoginRequest {
  user_name: string;
  password: string;
  client_id?: string;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
}

export interface SystemInfo {
  version: string;
  title: string;
  description: string;
  [key: string]: unknown;
}

export interface ScanStatus {
  running: boolean;
  last_scan_time: number;
  scanned_count: number;
  [key: string]: unknown;
}
