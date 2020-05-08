const firestore = require("firebase").firestore;

const projects = {
  "projects/1": {
    name: "project_1",
  },
  "projects/2": {
    name: "project_2",
  },
};

const build = {
  projectId: "1",
  startedAt: new firestore.Timestamp.now(),
  duration: 123,
  url: "url",
};

const builds = {
  "build/1": {
    projectId: "1",
    startedAt: new firestore.Timestamp.now(),
    duration: 234,
    url: "url",
  },
  "build/2": {
    projectId: "1",
    startedAt: new firestore.Timestamp.now(),
    duration: 345,
    url: "url1",
  },
};

const user = { uid: "uid" };

exports.getUser = function () {
  return user;
};

exports.getProjects = function () {
  return projects;
};

exports.getBuilds = function () {
  return builds;
};

exports.getBuild = function () {
  return Object.assign({}, build);
};
