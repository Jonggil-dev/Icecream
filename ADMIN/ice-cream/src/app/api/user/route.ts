import { NextRequest, NextResponse } from "next/server";
import dbConnect from "@/lib/mongodb";
import User from "@/models/User";
import bcrypt from "bcrypt";
import { signJwtAccessToken } from "@/lib/jwt";

interface UserApiRequest {
  email: string;
  password: string;
}

export async function POST(request: NextRequest) {
  await dbConnect();

  try {
    const { email, password }: UserApiRequest = await request.json();

    const user = await User.findOne({ email: email });

    if (user && (await bcrypt.compare(password, user.password))) {
      const userObj = user.toObject();
      const { password, ...userWithoutPass } = userObj;

      const accessToken = await signJwtAccessToken(userWithoutPass);
      const result = {
        ...userWithoutPass,
        accessToken,
      };

      return NextResponse.json(result, { status: 200 });
    } else {
      return NextResponse.json({ message: "Failed to login" }, { status: 400 });
    }
  } catch (error) {
    return NextResponse.json({ message: "Failed to login" }, { status: 500 });
  }
}
