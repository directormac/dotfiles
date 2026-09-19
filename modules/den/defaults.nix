{
  den,
  lib,
  withSystem,
  config,
  inputs,
  ...
}: let
  mergeInputs = inputs'': inputs'';

  mkAspectInputs = class: system:
    withSystem system (
      {inputs', ...}: {
        ${class}._module.args.inputs' = mergeInputs inputs';
      }
    );

  osAspectInputs = {host}:
    withSystem host.system (
      {inputs', ...}:
        {
          name = "inputs'/os";
          __scopeHandlers.inputs' = _: {
            resume =
              mergeInputs inputs'
              // {
                collisionPolicy = "den-wins";
              };
            state = {};
          };
        }
        // lib.optionalAttrs (host ? class) (mkAspectInputs host.class host.system)
    );

  userAspectInputs = {
    user,
    host,
  }:
    withSystem host.system (
      {inputs', ...}: {
        name = "inputs'/user";
        includes = map (c: mkAspectInputs c host.system) user.classes;
        __scopeHandlers.inputs' = _: {
          resume =
            mergeInputs inputs'
            // {
              collisionPolicy = "den-wins";
            };
          state = {};
        };
      }
    );

  hmAspectInputs = {home}:
    withSystem home.system (
      {inputs', ...}:
        {
          name = "inputs'/home";
          __scopeHandlers.inputs' = _: {
            resume =
              mergeInputs inputs'
              // {
                collisionPolicy = "den-wins";
              };
            state = {};
          };
        }
        // lib.optionalAttrs (home ? class) (mkAspectInputs home.class home.system)
    );

  mkAspectSelf = class: system:
    withSystem system (
      {self', ...}: {
        ${class}._module.args.self' = self';
      }
    );

  osAspectSelf = {host}:
    withSystem host.system (
      {self', ...}:
        {
          name = "self'/os";
          __scopeHandlers.self' = _: {
            resume = self';
            state = {};
          };
        }
        // lib.optionalAttrs (host ? class) (mkAspectSelf host.class host.system)
    );

  userAspectSelf = {
    user,
    host,
  }:
    withSystem host.system (
      {self', ...}: {
        name = "self'/user";
        includes = map (c: mkAspectSelf c host.system) user.classes;
        __scopeHandlers.self' = _: {
          resume = self';
          state = {};
        };
      }
    );

  hmAspectSelf = {home}:
    withSystem home.system (
      {self', ...}:
        {
          name = "self'/home";
          __scopeHandlers.self' = _: {
            resume = self';
            state = {};
          };
        }
        // lib.optionalAttrs (home ? class) (mkAspectSelf home.class home.system)
    );
in {
  # Reserve 'settings' so aspects can declare typed settings without pipeline dispatch
  den.reservedKeys = ["settings"];

  den.batteries.inputs' = lib.mkForce {
    name = "inputs'";
    includes = [
      osAspectInputs
      userAspectInputs
      hmAspectInputs
    ];
  };

  den.batteries.self' = lib.mkForce {
    name = "self'";
    includes = [
      osAspectSelf
      userAspectSelf
      hmAspectSelf
    ];
  };

  den.schema.host.includes = [
    # den.aspects.base.network.firewall-collector
    # den.aspects.base.secrets.collector
  ];

  den.schema.user.includes = [
    # den.aspects.base.users.resolved-user-emitter
  ];

  # Wire den batteries that every host/user should have
  den.default.includes = [
    den.batteries.define-user
    den.batteries.hostname
    # den.batteries.inputs'
    # den.batteries.self'
  ];
}
