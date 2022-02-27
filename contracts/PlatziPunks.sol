// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "./PlatziPunksDNA.sol";

contract PlatziPunksToken {
    function decimals() public view returns (uint8) {}

    function totalSupply() public view returns (uint256) {}

    function balanceOf(address _owner) public view returns (uint256 balance) {}

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {}

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {}

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {}
}

contract PlatziPunks is ERC721, ERC721Enumerable, PlatziPunksDNA {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _idCounter;
    uint256 public maxSupply;
    mapping(uint256 => uint256) public tokenDNA;

    address public tokenContract;

    uint256 public mintPrice;

    constructor(uint256 _maxSupply) ERC721("PlatziPunks", "PLPKS") {
        maxSupply = _maxSupply;
        tokenContract = 0x6fa2eD540a06C85f0cbD72aC6bFd7B2D8535b4a4;
        mintPrice = 1;
    }

    function mint() public {
        PlatziPunksToken punksToken = PlatziPunksToken(tokenContract);

        require(
            punksToken.balanceOf(msg.sender) >=
                (mintPrice * 10**punksToken.decimals()),
            "Mint price is 1 PKKS"
        );

        uint256 allowance = punksToken.allowance(msg.sender, tokenContract);
        require(
            allowance >= (mintPrice * 10**punksToken.decimals()),
            "Check the token allowance"
        );

        uint256 current = _idCounter.current();
        require(current < maxSupply, "No PlatziPunks left");

        tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);

        punksToken.transferFrom(
            msg.sender,
            tokenContract,
            (mintPrice * 10**punksToken.decimals())
        );

        _safeMint(msg.sender, current);
        _idCounter.increment();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://avataaars.io/";
    }

    function imageByDNA(uint256 _dna) public view returns (string memory) {
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI(_dna);

        return string(abi.encodePacked(baseURI, "?", paramsURI));
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
        string memory params;
        params = string(
            abi.encodePacked(
                "accessoriesType=",
                getAccessoriesType(_dna),
                "&clotheColor=",
                getClotheColor(_dna),
                "&clotheType=",
                getClotheType(_dna),
                "&eyeType=",
                getEyeType(_dna),
                "&eyebrowType=",
                getEyeBrowType(_dna),
                "&facialHairColor=",
                getFacialHairColor(_dna),
                "&facialHairType=",
                getFacialHairType(_dna),
                "&hairColor=",
                getHairColor(_dna),
                "&hatColor=",
                getHatColor(_dna),
                "&graphicType=",
                getGraphicType(_dna),
                "&mouthType=",
                getMouthType(_dna),
                "&skinColor=",
                getSkinColor(_dna)
            )
        );
        return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721 Metadata for non existing token");

        uint256 dna = tokenDNA[tokenId];

        string memory image = imageByDNA(dna);

        string memory jsonURI = Base64.encode(
            abi.encodePacked(
                '{ "name": "PlatziPunks #',
                tokenId.toString(),
                '", "description": "Platzi Punkss", "image" : "',
                image,
                '"}'
            )
        );

        return
            string(abi.encodePacked("data:application/json;base64,", jsonURI));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
