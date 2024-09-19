import argparse
import os

import cuemol.cuemol as cm
from cuemol.povrender import PovRender


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--infile", type=str, required=True, help="Input file")
    parser.add_argument("--outname", type=str, default=None)
    parser.add_argument("--pov", type=str, required=True, help="povray executable path")
    parser.add_argument("--povinc", type=str, required=True, help="povray include path")
    parser.add_argument(
        "--blendpng", type=str, required=True, help="blendpng executable path"
    )
    parser.add_argument("--nthreads", type=int, default=1)
    parser.add_argument("--radiosity_mode", type=int, default=-1)
    parser.add_argument("--start_frame", type=int, default=0)
    parser.add_argument("--num_frames", type=int, default=-1)
    parser.add_argument("--width", type=int, default=800)
    parser.add_argument("--height", type=int, default=600)
    args = parser.parse_args()

    cmd = cm.svc("CmdMgr")
    result = cmd.runCmdArgs(
        "load_scene",
        {"file_path": args.infile, "scene_name": "scene1", "file_format": "qsc_xml"},
    )
    scene = result["result_scene"]

    outname = args.outname
    if outname is None:
        # use basename of input file
        outname = os.path.splitext(args.infile)[0]

    rend = PovRender(
        width=args.width,
        height=args.height,
        povray_bin=args.pov,
        povray_inc=args.povinc,
        blendpng_bin=args.blendpng,
        rad_mode=args.radiosity_mode,
        nthr=args.nthreads,
    )
    # rend.render_simple(scene, outname)
    # return

    animMgr = scene.getAnimMgr()
    if animMgr.size > 0:
        rend.render_anim(scene, outname, args.start_frame, args.num_frames)
    else:
        rend.render_simple(scene, outname)


if __name__ == "__main__":
    main()
