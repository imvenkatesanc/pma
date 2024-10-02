import jwtDecode from 'jwt-decode';

const decodedToken = jwtDecode(token);
const isTokenExpired = decodedToken.exp * 1000 < Date.now(); // exp is in seconds
