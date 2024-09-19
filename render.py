import argparse

import cuemol.cuemol as cm
from cuemol.povrender import PovRender


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--infile", type=str, required=True, help="Input file")
    parser.add_argument("--pov", type=str, required=True, help="povray executable path")
    parser.add_argument("--povinc", type=str, required=True, help="povray include path")
    parser.add_argument(
        "--blendpng", type=str, required=True, help="blendpng executable path"
    )
    parser.add_argument("--nthreads", type=int, default=1)
    parser.add_argument("--radiosity_mode", type=int, default=-1)
    args = parser.parse_args()

    cmd = cm.svc("CmdMgr")
    result = cmd.runCmdArgs(
        "load_scene",
        {"file_path": args.infile, "scene_name": "scene1", "file_format": "qsc_xml"},
    )
    scene = result["result_scene"]

    rend = PovRender(
        width=800,
        height=600,
        povray_bin=args.pov,
        povray_inc=args.povinc,
        blendpng_bin=args.blendpng,
        rad_mode=args.radiosity_mode,
        nthr=args.nthreads,
    )
    rend.render_anim(scene, "test", 0, 100)


if __name__ == "__main__":
    main()

