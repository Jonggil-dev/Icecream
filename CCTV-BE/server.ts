// server framework
const express = require("express");
const app = express();
const cors = require("cors");
app.use(cors());
// socket.io
const { createServer } = require("http");
const { Server } = require("socket.io");
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});
// view engine
app.set("view engine", "ejs");
// HTML, CSS, JavaScript 파일 포함
app.use(express.static("public"));

// webpack 설정
const path = require("path");
const { InjectManifest } = require("workbox-webpack-plugin");

module.exports = {
  entry: "./public/index.js",
  output: {
    path: path.resolve(__dirname, "public"),
    filename: "bundle.js",
  },
  plugins: [
    new InjectManifest({
      swSrc: "./service-worker.js",
      swDest: "service-worker.js",
    }),
  ],
};

require("dotenv").config(); // .env 파일에서 환경변수 불러오기

const port = process.env.PORT || 1996;
const roomName = process.env.roomName || "chatRoom";
let cnt = 0;
// server port
server.listen(port, "0.0.0.0", () => {
  console.log("port에 서버 연결됨");
});

// room에 입장할 수 있는 제한인원 3명으로 설정
const roomCapacity = { [roomName]: 0 };
const maxRoomCapacity = 5;

// router
app.get("/", (req, res) => {
  res.send("it is for websocket");
});

// cctv send
app.get("/camera", (req, res) => {
  res.render("camera");
});

// cctv receive
app.get("/cctv", (req, res) => {
  // 초기 데이터 설정
  const initialData = {
    CCTVName: "CCTV 위치",
    CCTVImage: null,
  };
  res.render("cctv", { data: initialData }); // 'data' 객체를 전달
});

// // 서비스 워커 등록
// app.get("/sw.js", (req, res) => {
//   res.sendFile(path.resolve(__dirname, "public", "sw.js"));
// });

// socket.io
io.on("connect", socket => {
  console.log("user가 websocket에 들어왔습니다");
  // 인원 수 검증
  if (roomCapacity[roomName] < maxRoomCapacity) {
    // 방 참여
    socket.join(roomName);
    roomCapacity[roomName]++;
    console.log("현재 방에 참여한 인원", roomCapacity[roomName]);

    // cctv 이미지 받고 전송
    socket.on("sendCCTVImage", data => {
      // console.log(cnt++);
      io.to(roomName).emit("getCCTVImage", data);
    });

    socket.on("sendCCTVImage2", data => {
      io.to(roomName).emit("getCCTVImage2", data);
    });

    socket.on("sendSpeedData", data => {
      io.to(roomName).emit("getSpeedData", data);
    });

    // 방 퇴장
    socket.on("disconnect", data => {
      roomCapacity[roomName]--;
      console.log("user가 websocket에서 나갔습니다");
      console.log("현재 방에 참여한 인원", roomCapacity[roomName]);
    });
  } else {
    socket.emit("error", "방이 가득찼습니다");
  }
});
