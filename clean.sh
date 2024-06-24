cd ~/git/ltu-cmass

find . -type f -name 'timing_stats_*.txt' -ok rm -- {} \;
find . -type f -name 'allocation_stats_*.txt' -ok rm -- {} \;
find . -type f -name fft_wisdom -ok rm -- {} \;
