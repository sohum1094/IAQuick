import express from 'express';
import { createUserHandler, getUserHandler, updateUserHandler, deleteUserHandler } from '../controllers/userController.js';

const router = express.Router();

router.post('/', createUserHandler);
router.get('/:id', getUserHandler);
router.put('/:id', updateUserHandler);
router.delete('/:id',deleteUserHandler);

export default router;
