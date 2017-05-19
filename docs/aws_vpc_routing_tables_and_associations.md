## Routing tables and explicit associations

1. rtb-02c36c67 | Public_route_table (Main: Yes)

```
Subnet                                             CIDR
subnet-0916a96c (10.60.0.0/24) | public-1a         10.60.0.0/24
subnet-f10aa386 (10.60.100.0/24) | public-1b       10.60.100.0/24
```

2. rtb-b98629dc | private (Main: No)

```
Subnet                                             CIDR
subnet-f2bf6285 (10.60.1.0/24) | private-1b        10.60.1.0/24
subnet-ffe03b88 (10.60.2.0/24) | staging-apps      10.60.2.0/24
subnet-d3df5db6 (10.60.10.0/24) | prod-public-1a   10.60.10.0/24
subnet-c6812eb1 (10.60.20.0/24) | prod-public-1b   10.60.20.0/24
```

3. rtb-70982a15 | (no name) (Main: Yes)

```
Subnet                                             CIDR
subnet-6dae2008 (10.61.0.0/24) | public-1a         10.61.0.0/24
```
