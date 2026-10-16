# Fleet and per-host diagrams — generates TOPOLOGY.md with mermaid
# visualizations and per-host view files under diagrams/.
#
# Uses den's capture layer + den-diagram rendering library.
{
  lib,
  den,
  inputs,
  ...
}:
let
  allHosts = lib.concatMap builtins.attrValues (builtins.attrValues (den.hosts or { }));
  diagram = inputs.den-diagram.lib;
  stripFrontmatter =
    source:
    let
      body = builtins.filter (l: !(lib.hasPrefix "%%{init:" l)) lines;
      lines = lib.splitString "\n" source;
    in
    lib.concatStringsSep "\n" body;
in
{
  flake-file.inputs.den-diagram = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:denful/den-diagram";
  };

  perSystem =
    { pkgs, ... }:
    let
      inherit (diagram.export)
        entityEntries
        mkGallery
        mkWriteScript
        entriesToPackages
        ;
      allUsers =
        let
          inherit (fleetCapture) scopeEntityKind;
          allScopeIds = builtins.attrNames (fleetCapture.scopeParent or { });
          extractName =
            kind: scopeId:
            let
              matching = builtins.filter (p: lib.hasPrefix "${kind}=" p) parts;
              parts = lib.splitString "," scopeId;
            in
            if matching == [ ] then null else lib.removePrefix "${kind}=" (builtins.head matching);
          userScopes = builtins.filter (s: (scopeEntityKind.${s} or null) == "user") allScopeIds;
        in
        lib.concatMap (
          s:
          let
            hostName = extractName "host" s;
            userName = extractName "user" s;
          in
          lib.optional (userName != null && hostName != null) {
            inherit userName hostName;
            name = "${hostName}-${userName}";
          }
        ) userScopes;
      # --- Assembly ---
      everyEntry = hostEntries ++ hostSummaryEntries ++ userEntries ++ fleetViewEntries;
      fleetCapture = den.lib.capture.captureFleet { };
      fleetDagSource = rc.render.toFleetDagMermaid { inherit fleetCapture hostGraphs; };
      fleetDagView = {
        md = pkgs.writeText "fleet-dag.md" "# Fleet DAG\n\n![Fleet DAG](./fleet-dag.mmd.svg)\n\n```mermaid\n${fleetDagSource}\n```\n";
        svg = rc.mmdSourceToSvg "fleet-dag" fleetDagSource;
      };
      fleetGallery = {
        drv = mkGallery pkgs {
          dir = "fleet";
          entries = everyEntry;
          name = "fleet";
          title = "Fleet Gallery";
        };

        path = "diagrams/fleet.md";
      };
      fleetIrDrv = pkgs.runCommand "fleet-ir.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
        echo ${
          lib.escapeShellArg (diagram.fleetGraph.toJSON { inherit fleetCapture hostGraphs; })
        } | jq . > $out
      '';
      fleetSummaryDrv = pkgs.writeText "fleet-summary.md" (diagram.text.fleetSummary fleetCapture);
      fleetSummaryText = diagram.text.fleetSummary fleetCapture;
      fleetViewEntries =
        mkFleetEntries "pipe-flow" pipeFlowView
        ++ mkFleetEntries "scope-topology" scopeTopoView
        ++ mkFleetEntries "policy-resolution" policyMapView
        ++ mkFleetEntries "pipe-sequence" pipeSeqView
        ++ mkFleetEntries "fleet-dag" fleetDagView
        ++ mkFleetEntries "namespace" namespaceView
        ++ [
          {
            dir = "fleet";
            drv = fleetSummaryDrv;
            ext = "md";
            name = "fleet";
            tool = null;
            view = "summary";
          }
          {
            dir = "fleet";
            drv = fleetIrDrv;
            ext = "json";
            name = "fleet";
            tool = null;
            view = "fleet-ir";
          }
        ];
      galleries = hostGalleries ++ userGalleries ++ [ fleetGallery ];
      graphClasses = entity: lib.unique (lib.concatMap (n: n.classes or [ ]) entity.nodes);
      hostEntries = lib.concatMap (
        host:
        let
          entity = hostGraphs.${host.name};
        in
        entityEntries { inherit pkgs rc; } {
          inherit entity;
          inherit (host) name;
          dir = "hosts/${host.name}";
          viewDefs = hostViewDefs (graphClasses entity);
        }
      ) allHosts;
      # --- Galleries ---
      hostGalleries = map (host: {
        drv = mkGallery pkgs {
          inherit (host) name;
          dir = "hosts/${host.name}";
          entries = everyEntry;
          title = "Gallery: ${host.name}";
        };

        path = "diagrams/hosts/${host.name}.md";
      }) allHosts;
      # --- Scope projection ---
      hostGraphs = lib.listToAttrs (
        map (host: {
          inherit (host) name;

          value = diagram.projectScope {
            inherit fleetCapture;
            inherit (host) name;
            kind = "host";
          };
        }) allHosts
      );
      # --- Per-host summaries ---
      hostSummaryDrvs = lib.listToAttrs (
        map (
          host:
          let
            entity = hostGraphs.${host.name};
            text = diagram.text.hostSummary {
              inherit fleetCapture;
              graph = entity;
            };
          in
          {
            name = "${host.name}-summary";
            value = pkgs.writeText "${host.name}-summary.md" text;
          }
        ) allHosts
      );
      hostSummaryEntries = map (host: {
        inherit (host) name;
        dir = "hosts/${host.name}";
        drv = hostSummaryDrvs."${host.name}-summary";
        ext = "md";
        tool = null;
        view = "summary";
      }) allHosts;
      # --- Per-host entries ---
      hostViewDefs = classes: rc.views.host ++ rc.views.classViews classes;
      # Patched mermaid-cli: swap bundled mermaid for 11.14.0 if present
      mermaidCliPatched = pkgs.mermaid-cli.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          mermaid_dir="$out/lib/node_modules/@mermaid-js/mermaid-cli/node_modules/mermaid"
          if [ -d "$mermaid_dir" ]; then
            rm -rf "$mermaid_dir"
            mkdir -p "$mermaid_dir"
            ${pkgs.gnutar}/bin/tar -xzf ${
              pkgs.fetchurl {
                hash = "sha256-Y7oGZJ4X4Q/uAuVMfC7az+JQtLvds8JJfwDToypC5cc=";
                url = "https://registry.npmjs.org/mermaid/-/mermaid-11.14.0.tgz";
              }
            } -C "$mermaid_dir" --strip-components=1
          fi
        '';
      });
      mkFleetEntries = viewName: view: [
        {
          dir = "fleet";
          drv = view.md;
          ext = "md";
          name = "fleet";
          tool = null;
          view = viewName;
        }
        {
          dir = "fleet";
          drv = view.svg;
          ext = "svg";
          name = "fleet";
          tool = "mmd";
          view = viewName;
        }
      ];
      # --- Fleet view entries (md + svg pairs) ---
      mkFleetView =
        name: title: renderFn:
        let
          md = pkgs.writeText "${name}.md" "# ${title}\n\n![${title}](./${name}.mmd.svg)\n\n```mermaid\n${source}\n```\n";
          source = renderFn fleetCapture;
          svg = rc.mmdSourceToSvg name source;
        in
        {
          inherit md svg;
        };
      # --- TOPOLOGY.md sections (inline mermaid for GitHub rendering) ---
      mkInlineSection =
        title: renderFn:
        let
          source = stripFrontmatter (renderFn fleetCapture);
        in
        ''
          ## ${title}

          ```mermaid
          ${source}
          ```
        '';
      namespaceGraph = diagram.graph.ofNamespace {
        inherit (den) aspects;
        filter = v: v.name != "wsl-host-aspect";
      };
      namespaceSource = rc.renderDense.toMermaid namespaceGraph;
      namespaceView = {
        md = pkgs.writeText "namespace.md" "# Namespace\n\n![Namespace](./namespace.mmd.svg)\n\n```mermaid\n${namespaceSource}\n```\n";
        svg = rc.mmdSourceToSvg "namespace" namespaceSource;
      };
      pipeFlowView = mkFleetView "pipe-flow" "Pipe Flow" rc.render.toPipeFlowMermaid;
      pipeSeqView = mkFleetView "pipe-sequence" "Pipe Sequence" rc.render.toPipeSequenceMermaid;
      policyMapView =
        mkFleetView "policy-resolution" "Policy Resolution Map"
          rc.render.toPolicyResolutionMapMermaid;
      rc = diagram.renderContext {
        inherit pkgs theme;
        mermaidCli = mermaidCliPatched;

        mermaidConfig = {
          elk = {
            mergeEdges = true;
            nodePlacementStrategy = "BRANDES_KOEPF";
          };

          flowchart.wrappingWidth = 600;
          layout = "elk";
        };
      };
      scopeTopoView = mkFleetView "scope-topology" "Scope Topology" rc.render.toScopeTopologyMermaid;
      theme = diagram.themeFromBase16 {
        inherit pkgs;
        scheme = "catppuccin-mocha";
      };
      # --- TOPOLOGY.md ---
      topologyDrv = pkgs.writeText "TOPOLOGY.md" (
        lib.concatStringsSep "\n" [
          "# Fleet Topology"
          ""
          "Auto-generated visualizations of the nix-config fleet's"
          "aspect-resolution pipeline, scope tree, and data flow."
          ""
          (mkInlineSection "Scope Topology" rc.render.toScopeTopologyMermaid)
          (mkInlineSection "Policy Resolution" rc.render.toPolicyResolutionMapMermaid)
          (mkInlineSection "Pipe Flow" rc.render.toPipeFlowMermaid)
          (mkInlineSection "Pipe Sequence" rc.render.toPipeSequenceMermaid)
          ''
            ## Fleet Summary

            ${fleetSummaryText}
          ''
        ]
      );
      userEntries = lib.concatMap (
        u:
        let
          entity = diagram.projectScope {
            inherit fleetCapture;
            kind = "user";
            name = u.userName;
          };
        in
        entityEntries { inherit pkgs rc; } {
          inherit entity;
          dir = "hosts/${u.hostName}/users/${u.userName}";
          name = u.userName;
          viewDefs = userViewDefs (graphClasses entity);
        }
      ) allUsers;
      userGalleries = map (u: {
        drv = mkGallery pkgs {
          dir = "hosts/${u.hostName}/users/${u.userName}";
          entries = everyEntry;
          name = u.userName;
          title = "Gallery: ${u.userName} @ ${u.hostName}";
        };

        path = "diagrams/hosts/${u.hostName}/users/${u.userName}.md";
      }) allUsers;
      # --- Per-user entries ---
      # Discover users from fleet capture scope data (not host.users)
      userViewDefs = classes: rc.views.user ++ rc.views.classViews classes;
    in
    {
      # Diagram packages live in legacyPackages to avoid forcing the expensive
      # fleet capture + graph rendering when the eval cache walks packages.*.
      legacyPackages.diagrams =
        entriesToPackages everyEntry
        // hostSummaryDrvs
        // {
          fleet-summary = fleetSummaryDrv;

          write-diagrams = mkWriteScript pkgs {
            inherit galleries;
            destExpr = ''"$(${pkgs.git}/bin/git rev-parse --show-toplevel)"'';
            entries = everyEntry;
            readmeDrv = topologyDrv;
          };

          write-topology = pkgs.writeShellScriptBin "write-topology" ''
            dest="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
            cp ${topologyDrv} "$dest/TOPOLOGY.md"
            chmod 644 "$dest/TOPOLOGY.md"
            echo "Wrote $dest/TOPOLOGY.md"
          '';
        };
    };
}
