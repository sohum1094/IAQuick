import { createUser, getUserById } from '../models/userModel.js';

export const createUserService = async (userData) => {
    return await createUser(userData);
};

export const getUserService = async (id) => {
    return await getUserById(id);
};
