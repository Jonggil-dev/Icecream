"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import { signOut, useSession } from "next-auth/react";
import io from "socket.io-client";
import Navbar from "./navbar";
import { v4 as uuidv4 } from "uuid";

const SOCKET_SERVER_URL = `${process.env.NEXT_PUBLIC_SOCKET_SERVER_URL}`;
const MAX_LIST_SIZE = 9;

const Home = () => {
  const router = useRouter();
  const pathname = usePathname();
  const { data: session, status: sessionStatus } = useSession();
  const [cctvImage, setCctvImage] = useState<string | null>(null);
  const [cctvName, setCctvName] = useState<string>("오션초등학교 CCTV");
  const [speedDataList, setSpeedDataList] = useState<
    {
      id: string;
      time: string;
      speed: number;
      isNew: boolean;
    }[]
  >([]);

  useEffect(() => {
    if (sessionStatus === "unauthenticated" && pathname !== "/login") {
      router.replace("/login");
    }
  }, [sessionStatus, router, pathname]);

  useEffect(() => {
    if (sessionStatus === "authenticated") {
      const socket = io(SOCKET_SERVER_URL);

      socket.on("connect", () => {
        console.log("Connected to WebSocket server.");
      });

      socket.on("getCCTVImage2", (data: { CCTVImage: ArrayBuffer }) => {
        // console.log("Received data from getCCTVImage2", data);
        // const blob = new Blob([data.CCTVImage], { type: "image/jpeg" });
        // const imageUrl = URL.createObjectURL(blob);
        // setCctvImage(imageUrl);
        const base64Image = arrayBufferToBase64(data.CCTVImage);
        setCctvImage(base64Image);
      });

      socket.on("getSpeedData", (data: { time: number; speed: number }) => {
        const formattedTime = formatUnixTimestamp(data.time);
        const newSpeedData = {
          id: uuidv4(),
          time: formattedTime,
          speed: data.speed,
          isNew: true,
        };

        setSpeedDataList((prevList) => {
          const updatedList = [newSpeedData, ...prevList];
          if (updatedList.length > MAX_LIST_SIZE) {
            updatedList.pop();
          }
          return updatedList;
        });

        setTimeout(() => {
          setSpeedDataList((prevList) =>
            prevList.map((item) =>
              item.id === newSpeedData.id ? { ...item, isNew: false } : item
            )
          );
        }, 2000);
      });

      return () => {
        socket.disconnect();
      };
    }
  }, [sessionStatus]);

  return (
    sessionStatus === "authenticated" && (
      <>
        <Navbar />
        <main className="h-screen overflow-hidden pt-20 sm:pt-0">
          <div className="grid grid-cols-1 sm:grid-cols-8 md:grid-cols-8 h-full">
            <div className="col-span-1 md:col-span-6 sm:col-span-6 flex items-center justify-center bg-zinc-500">
              <div className="w-full h-full-4 flex flex-col items-center justify-center">
                <h1 className="absolute top-24 sm:top-20 font-bold sm:mt-0 left-3 p-2 text-xl sm:text-3xl">
                  {cctvName}
                </h1>
                {cctvImage ? (
                  <img
                    src={`data:image/jpeg;base64,${cctvImage}`}
                    alt="CCTV"
                    className="mt-8"
                  />
                ) : (
                  // <img src={cctvImage} alt="CCTV" />
                  <p className="text-xl">CCTV가 연결되지 않음</p>
                )}
              </div>
            </div>
            <div className="col-span-1 md:col-span-2 sm:col-span-2 bg-black flex flex-col justify-end items-center h-full">
              <h3 className="text-white mt-10 sm:mt-20 mb-5 text-2xl sm:text-2xl hidden sm:block whitespace-nowrap">
                과속 발생 현황
              </h3>
              <div className="text-white flex-grow w-full border-4 border-red-500 overflow-y-auto px-5 flex flex-col justify-center items-center">
                {speedDataList.length > 0 ? (
                  speedDataList.map((data, index) => (
                    <div
                      key={data.id}
                      className={`text-white my-1 text-lg text-center ${
                        data.isNew ? "animate-blink" : ""
                      }`}
                    >
                      <div>{data.time}</div>
                      <div>
                        속도 :{" "}
                        <span className="text-red-500">{data.speed} km/h</span>
                      </div>
                    </div>
                  ))
                ) : (
                  <p className="whitespace-nowrap">과속 차량 없음</p>
                )}
              </div>
            </div>
          </div>
        </main>
      </>
    )
  );
};

export default Home;

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  let binary = "";
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}

function formatUnixTimestamp(timestamp: number): string {
  const date = new Date(timestamp * 1000);
  const hours = String(date.getHours()).padStart(2, "0");
  const minutes = String(date.getMinutes()).padStart(2, "0");
  const seconds = String(date.getSeconds()).padStart(2, "0");
  return `${hours}시${minutes}분${seconds}초`;
}
