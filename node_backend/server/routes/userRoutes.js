import express from 'express';
import { createUserHandler, getUserHandler } from '../controllers/userController.js';

const router = express.Router();

router.post('/', createUserHandler);
router.get('/:id', getUserHandler);

export default router;
