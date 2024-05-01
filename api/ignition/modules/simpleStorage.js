const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("simpleStorage", (m) => {
  const simpleStorage = m.contract("SimpleStorage");

  m.call(simpleStorage, "set", [500]);

  return { simpleStorage };
});
