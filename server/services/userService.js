import UserModel from '../models/userModel.js';

export const getUserService = (id) => {
    return UserModel.findById(id);
};

export const createUserService = (userData) => {
    return UserModel.create(userData);
};
