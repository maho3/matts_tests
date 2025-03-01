
from copy import deepcopy
from cmass.bias.tools.hod_models import logM_i
from scipy.special import erf
from cmass.bias.apply_hod import load_snapshot
from numpy.random import randn
from cmass.lightcone import lc
from cmass.infer.loaders import get_cosmo
from omegaconf import OmegaConf
import os
from os.path import join
import numpy as np

from astropy.cosmology import Planck18
import sys
cosmo = Planck18

wdir = '/anvil/scratch/x-mho1/cmass-ili'
outdir = '/anvil/scratch/x-mho1/cmass-ili/scratch/hodz'

nbody = 'mtnglike'
sim = 'fastpm'
L, N = 3000, 384
if len(sys.argv) > 1:
    lhid = int(sys.argv[1])
else:
    lhid = 0
print(lhid)
zmin, zmax = 0.45, 0.7

simdir = join(wdir, nbody, sim, f'L{L:d}-N{N:d}', str(lhid))

cosmo = get_cosmo(simdir)
cfg = OmegaConf.load(join(simdir, 'config.yaml'))

boss_dir = '/anvil/scratch/x-mho1/cmass-ili/obs'
maskobs = lc.Mask(boss_dir=boss_dir, veto=False)
snap_times = sorted(cfg.nbody.asave)[::-1]  # decreasing order
snap_times = snap_times[5:6]
lightcone = lc.Lightcone(
    boss_dir=None,
    mask=maskobs,
    Omega_m=cfg.nbody.cosmo[0],
    zmin=zmin,
    zmax=zmax,
    snap_times=snap_times,
    verbose=True,
    augment=0,
    seed=42
)


def hod_fct(
        snap_idx: int,
        hlo_idx: np.ndarray[np.uint64],
        z: np.ndarray[np.float64]) -> tuple:

    # as an example, only halos with certain redshifts get galaxies. Each gets a pair of galaxies.
    # I set the delta_x and delta_v very small so it should be possible to see these pairs in the output
    hlo_idx_out = np.arange(0, len(hlo_idx), dtype=np.uint64)
    delta_x = randn(len(hlo_idx_out), 3) * 0.01
    delta_v = randn(len(hlo_idx_out), 3) * 1.0

    return hlo_idx_out, delta_x, delta_v


lightcone.set_hod(hod_fct)


# add some snapshots

for snap_idx, a in enumerate(snap_times):
    hpos, hvel, hmass, hmeta = load_snapshot(simdir, a)
    hpos = hpos.astype(np.float64)
    hvel = hvel.astype(np.float64)
    hmass = hmass

    lightcone.add_snap(snap_idx, hpos, hvel)

ra, dec, z, galid = lightcone.finalize()


def split_galid(gid):
    return np.divmod(gid, 2**((gid.itemsize-1)*8))


galsnap, galidx = split_galid(galid)
print(f'{galsnap.min()} <= galsnap <= {galsnap.max()}')
print(f'{galidx.min()} <= galidx <= {galidx.max()}')


mass = np.empty_like(galidx, dtype=np.float64)

for snap_idx, a in enumerate(snap_times):
    print(f'Loading snapshot {snap_idx}...')
    hpos, hvel, hmass, hmeta = load_snapshot(simdir, a)

    mask = np.isin(galsnap, snap_idx)
    idxs = galidx[mask]
    mass[mask] = hmass[idxs]


def cenocc(logM, redshift, params):
    logMmin, sigma_logM, mucen, zpivot = params
    logMmin_z = logM_i(redshift, logMmin, mucen, zpivot)
    mean_ncen = 0.5 * (
        1.0
        + erf((logM - logMmin_z) / (sigma_logM))
    )
    return mean_ncen


def satocc(logM, redshift, pcen, params):
    logM0, logM1, alpha, musat, zpivot = params
    logM0_z = logM_i(redshift, logM0, musat, zpivot)
    logM1_z = logM_i(redshift, logM1, musat, zpivot)

    m = logM > logM0_z
    mean_nsat = np.zeros_like(logM)
    mean_nsat[m] = pcen[m] * (
        (10**logM[m] - 10**logM0_z[m]) / 10**logM1_z[m]
    )**alpha
    return mean_nsat


def calcH(mass, z, z_bins, params):
    p = [*params[:3], params[-1]]
    mean_ncen = cenocc(mass, z, p)
    p = params[3:]
    mean_nsat = satocc(mass, z, mean_ncen, p)

    ncen_hist, _ = np.histogram(z, bins=z_bins, weights=mean_ncen)
    nsat_hist, _ = np.histogram(z, bins=z_bins, weights=mean_nsat)
    return ncen_hist, nsat_hist


prior_range = np.array([
    (12.8, 13.2),  # logMmin
    (0.1, 1.0),  # sigma_logM
    (-30, 0),  # mucen
    (12.8, 15.0),  # logM0
    (12.8, 15.0),  # logM1
    (0.5, 2),  # alpha
    (-10, 0),  # musat
    (0.45, 0.7),  # zpivot
])

Nhod = 10
z_bins = np.linspace(zmin, zmax, 20)

for i in range(Nhod):
    idx = 10*lhid + i
    print(f'{idx:06d}')

    np.random.seed(idx)
    params = np.random.uniform(prior_range[:, 0], prior_range[:, 1])

    ncen_hist, nsat_hist = calcH(mass, z, z_bins, params)

    outparams = np.concatenate([cosmo, params])
    out = dict(lhid=lhid, seed=idx, params=outparams,
               ncen_hist=ncen_hist, nsat_hist=nsat_hist)
    np.savez(join(outdir, f'{idx:06d}.npz'), **out)
