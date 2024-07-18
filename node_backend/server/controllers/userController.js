import { createUserService, getUserService, updateUserService, deleteUserService } from '../services/userService.js';

export const createUserHandler = async (req, res) => {
    const userData = req.body;
    const newUser = await createUserService(userData);
    res.json(newUser);
};

export const getUserHandler = async (req, res) => {
    const { id } = req.params;
    const user = await getUserService(id);
    res.json(user);
};

export const updateUserHandler = async (req, res) => {
    const userData = req.body;
    const { id } = req.params;
    const updatedUser = await updateUserService(id, userData);
    res.json(updatedUser);
};

export const deleteUserHandler = async (req, res) => {
    const { id } = req.params;
    const deletedUser = await deleteUserService(id);
    res.json(deletedUser);
};
