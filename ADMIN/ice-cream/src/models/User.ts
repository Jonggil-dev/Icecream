import mongoose from "mongoose";

interface IUser extends mongoose.Document {
  username: string;
  email: string;
  password: string;
}

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
  },
  { versionKey: false }
);

const User = mongoose.models.User || mongoose.model<IUser>("User", userSchema);

export default User;
