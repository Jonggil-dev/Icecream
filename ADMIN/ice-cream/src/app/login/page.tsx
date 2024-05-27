"use client";

import { useRef, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { signIn, useSession } from "next-auth/react";

export default function LoginForm() {
  const router = useRouter();
  const pathname = usePathname();
  const { data: session, status: sessionStatus } = useSession();

  useEffect(() => {
    if (sessionStatus === "authenticated" && pathname !== "/") {
      router.replace("/");
    }
  }, [sessionStatus, router, pathname]);

  const email = useRef<HTMLInputElement>(null);
  const password = useRef<HTMLInputElement>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (email.current && password.current) {
      const res = await signIn("credentials", {
        redirect: false,
        email: email.current.value,
        password: password.current.value,
      });

      if (res?.ok) {
        router.replace("/");
      } else {
        alert("이메일 또는 비밀번호를 확인하세요");
      }
    }
  };

  return (
    sessionStatus === "unauthenticated" && (
      <>
        <h1 className="text-center font-bold text-3xl m-10">
          아이스크림 관리자 페이지
        </h1>
        <p className="text-center font-bold text-red-500 m-1">
          관리자용 서비스입니다.
          <br />
          관리자 계정으로 로그인하세요.
        </p>

        <div className="mx-auto p-10 w-[500px] h-[230px] bg-blue-100 rounded-lg text-center">
          <form onSubmit={handleSubmit}>
            <div className="flex justify-between my-2">
              <label htmlFor="id" className="text-lg">
                EMAIL
              </label>
              <input
                type="text"
                name="email"
                ref={email}
                className="shadow appearance-none border rounded py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              />
            </div>
            <div className="flex justify-between my-2">
              <label htmlFor="password" className="text-lg">
                PASSWORD
              </label>
              <input
                type="password"
                name="password"
                ref={password}
                className="shadow appearance-none border rounded py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
              />
            </div>
            <button
              type="submit"
              className="shadow bg-blue-500 hover:bg-blue-400 focus:shadow-outline focus:outline-none text-white font-bold py-3 px-5 rounded my-3"
            >
              로그인
            </button>
          </form>
        </div>
      </>
    )
  );
}
