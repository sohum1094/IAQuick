import { getUserService, createUserService } from '../services/userService.js';

export const getUser = (req, res) => {
    const user = getUserService(req.params.id);
    res.json(user);
};

export const createUser = (req, res) => {
    const newUser = createUserService(req.body);
    res.json(newUser);
};

export const deleteUser = (req, res) => {
   
    console.log("todo /userInfo/deleteUser");

};