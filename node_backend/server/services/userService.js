import { createUser, getUserById, updateUserById, deleteUserById } from '../models/userModel.js';

export const createUserService = async (userData) => {
    return await createUser(userData);
};

export const getUserService = async (id) => {
    return await getUserById(id);
};

export const updateUserService = async (id, newUserData) => {
    return await updateUserById(id, newUserData);
};

export const deleteUserService = async (id) => {
    return await deleteUserById(id);
};
