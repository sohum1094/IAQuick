import express from 'express';
import { getUser, createUser, deleteUser } from '../controllers/userController.js';

const router = express.Router();

router.get('/:id', getUser);
router.post('/', createUser);
router.delete('/',deleteUser);

export default router;
