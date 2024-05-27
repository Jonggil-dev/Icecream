import React from "react";
import Link from "next/link";
import { signOut } from "next-auth/react";

const Navbar: React.FC = () => {
  const KIBNANA_URL = `${process.env.NEXT_PUBLIC_KIBANA_URL}`;
  const JENKINS_URL = `${process.env.NEXT_PUBLIC_JENKINS_URL}`;
  return (
    <nav className="w-full bg-black text-white p-4 flex justify-between fixed top-0 z-10">
      <div className="flex space-x-8 text-2xl">
        <Link href="/" className="hover:text-gray-400 ml-5">
          ADMIN
        </Link>
        <Link href={KIBNANA_URL} className="hover:text-gray-400">
          KIBANA
        </Link>
        <Link href={JENKINS_URL} className="hover:text-gray-400">
          JENKINS
        </Link>
      </div>
      <div className="ml-auto">
        <button
          className="p-1 px-6 btn-delete text-xl"
          onClick={() => {
            signOut();
          }}
        >
          로그아웃
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
