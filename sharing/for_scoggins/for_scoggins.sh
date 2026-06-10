cd ~/git/ltu-cmass

for i in 324 391 401 406 444 485 502 592 694 926 944 1026 1122 1323 1515 1582 1608 1696 1702 1710 1951
do
        echo ${i}
        python -m cmass.nbody.jax1lpt --lhid ${i} --matchIC
done
