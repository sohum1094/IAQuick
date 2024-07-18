import { createUserService, getUserService, updateUserService, deleteUserService } from '../services/userService.js';

export const createUserHandler = async (req, res) => {
    try {
        const userData = req.body;
        const newUser = await createUserService(userData);
        res.json(newUser);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

export const getUserHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const user = await getUserService(id);
        res.json(user);
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
};

export const updateUserHandler = async (req, res) => {
    try {
        const userData = req.body;
        const { id } = req.params;
        const updatedUser = await updateUserService(id, userData);
        res.json(updatedUser);
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
};

export const deleteUserHandler = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedUser = await deleteUserService(id);
        res.json(deletedUser);
    } catch (error) {
        res.status(error.status || 500).json({ error: error.message });
    }
};
