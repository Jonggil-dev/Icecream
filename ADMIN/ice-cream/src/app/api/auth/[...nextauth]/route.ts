import NextAuth from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";

const authOptions = {
  providers: [
    CredentialsProvider({
      id: "credentials",
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        try {
          const res = await fetch(`${process.env.NEXTAUTH_URL}/api/user`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              email: credentials?.email,
              password: credentials?.password,
            }),
          });
          if (!res.ok) {
            throw new Error("Failed to login");
          }
          const user = await res.json();

          if (user) {
            console.log(user);
            return user;
          } else {
            return null;
          }
        } catch (error: any) {
          throw new Error(error);
        }
      },
    }),
  ],
  session: {
    maxAge: 60 * 60,
    updateAge: 30 * 60,
  },
  callbacks: {
    async jwt({ token, user }: any) {
      return { ...token, ...user };
    },
    async session({ session, token }: any) {
      session.user = token as any;
      console.log(session.user);
      return session;
    },
  },
};

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
