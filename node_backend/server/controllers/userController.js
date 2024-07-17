import { createUserService, getUserService } from '../services/userService.js';

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
