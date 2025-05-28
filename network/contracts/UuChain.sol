// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UuChain {
    struct UndangUndang {
        bytes32 hash_uu;
        string judul;
        string isi;
        uint256 tanggalMulai;
        uint256 tanggalBerakhir;
        address pembuat;
        bytes32 txHash; // tambah field txHash
    }

    UndangUndang[] public daftarUU;

    event UUDibuat(
            bytes32 hash_uu,
            string judul,
            address indexed pembuat,
            bytes32 txHash // emit txHash juga
        );

        function buatUU(
        bytes32 hash_uu,
        string memory _judul,
        string memory _isi,
        uint256 _tanggalMulai,
        uint256 _tanggalBerakhir
    ) public {
        daftarUU.push(UndangUndang({
            hash_uu: hash_uu,
            judul: _judul,
            isi: _isi,
            tanggalMulai: _tanggalMulai,
            tanggalBerakhir: _tanggalBerakhir,
            pembuat: msg.sender,
            txHash: hash_uu
        }));

        emit UUDibuat(hash_uu, _judul, msg.sender, hash_uu);
    }

    function getUU(uint256 _index) public view returns (
        bytes32 hash_uu,
        string memory judul,
        string memory isi,
        uint256 tanggalMulai,
        uint256 tanggalBerakhir,
        address pembuat,
        bytes32 txHash // tambahkan txHash pada return
    ) {
        require(_index < daftarUU.length, "UU tidak ditemukan.");
        UndangUndang memory uu = daftarUU[_index];
        return (
            uu.hash_uu,
            uu.judul,
            uu.isi,
            uu.tanggalMulai,
            uu.tanggalBerakhir,
            uu.pembuat,
            uu.txHash
        );
    }

    function jumlahUU() public view returns (uint256) {
        return daftarUU.length;
    }

    // Fungsi untuk ambil semua UU
    function getSemuaUU() public view returns (
        bytes32[] memory hash_uuList,
        string[] memory judulList,
        string[] memory isiList,
        uint256[] memory mulaiList,
        uint256[] memory berakhirList,
        address[] memory pembuatList,
        bytes32[] memory txHashList // tambahkan txHashList
    ) {
        uint256 len = daftarUU.length;
        hash_uuList = new bytes32[](len);
        judulList = new string[](len);
        isiList = new string[](len);
        mulaiList = new uint256[](len);
        berakhirList = new uint256[](len);
        pembuatList = new address[](len);
        txHashList = new bytes32[](len);

        for (uint256 i = 0; i < len; i++) {
            UndangUndang memory uu = daftarUU[i];
            hash_uuList[i] = uu.hash_uu;
            judulList[i] = uu.judul;
            isiList[i] = uu.isi;
            mulaiList[i] = uu.tanggalMulai;
            berakhirList[i] = uu.tanggalBerakhir;
            pembuatList[i] = uu.pembuat;
            txHashList[i] = uu.txHash;
        }
    }
}
