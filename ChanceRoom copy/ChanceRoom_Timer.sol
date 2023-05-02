// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * ========================= VERSION_2.0.0 ==============================
 *   ██       ██████  ████████ ████████    ██      ██ ███    ██ ██   ██
 *   ██      ██    ██    ██       ██       ██      ██ ████   ██ ██  ██
 *   ██      ██    ██    ██       ██       ██      ██ ██ ██  ██ █████
 *   ██      ██    ██    ██       ██       ██      ██ ██  ██ ██ ██  ██
 *   ███████  ██████     ██       ██    ██ ███████ ██ ██   ████ ██   ██    
 * ======================================================================
 *  ================ Open source smart contract on EVM =================
 *   ============== Verify Random Function by ChainLink ===============
 */

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../utils/TemplateView.sol";
import "../utils/AppStorage.sol";
import "../utils/VRFConsumer.sol";
import "../utils/Swapper.sol";
import "../utils/OwnableFactory.sol";


contract ChanceRoom_Timer is Initializable, OwnableFactory, TemplateView, ERC721Holder, ERC721Upgradeable, ERC721EnumerableUpgradeable, VRFConsumer, Swapper {
    using Strings for uint256;

    event Trigger(address msgSender);

    string constant implName = "Timer";
    address immutable implAddr;

    constructor(IFactory chanceRoomFactory)
        OwnableFactory(chanceRoomFactory)
    {
        implAddr = address(this);
    }


    function initialize(
        string memory tempName,
        address _nftAddr,
        uint256 _nftId,
        uint256 _duration,
        uint256 _ticketPrice,
        int256 _priceRate
    ) initializer onlyOwner public {
        __ERC721_init_unchained(
            string.concat("ChanceRoom_Hall on ", IERC721Metadata(_nftAddr).name(), " : ", _nftId.toString()), 
            "CRH"
        );
        (address tempAddr,) = ChanceRoomFactory.tempLatestVersion(tempName);
        AppStorage.layout().Address.tempAddr = tempAddr;
        AppStorage.layout().Address.nftAddr = _nftAddr;
        AppStorage.layout().Uint256.nftId = _nftId;
        AppStorage.layout().Uint256.deadLine = block.timestamp + _duration;
        AppStorage.layout().Uint256.ticketPrice = _ticketPrice;
        AppStorage.layout().Int256.priceRate = _priceRate;
        IERC721(_nftAddr).transferFrom(msg.sender, address(this), _nftId);
        _safeMint(address(this), 0);
    } 

    function layout() public pure returns(AppStorage.Layout memory) {
        return AppStorage.layout();
    }

    function chainId() public view returns(uint256 id) {
        assembly{
            id := chainid()
        }
    }

    function lockedNFT() public view returns(
        string memory name,
        address addr, 
        uint256 id
    ) {
        addr = AppStorage.layout().Address.nftAddr;
        id = AppStorage.layout().Uint256.nftId;
        name = IERC721Metadata(addr).name();
    }

    function implInfo() public view returns (
        string memory name,
        address addr
    ) {
        name = implName;
        addr = implAddr;
    }

    function template() public view returns(
        string memory name,
        address addr
    ) {

        addr = AppStorage.layout().Address.tempAddr;
        name = ITemplate(addr).name();
    }

    function info() public view returns(
        string memory _name,
        string memory _rule,
        uint256 _initTime
    ) {
        _name = name();
        _rule = "TIMER LOTTERY: tick tock until the trigger pulled";
    }

    function ticketPrice() public view returns(uint256 price) {
        price = uint256(
            int(AppStorage.layout().Uint256.ticketPrice) +
            int(AppStorage.layout().Uint256.ticketPrice) * int(totalSupply()) * int(AppStorage.layout().Int256.priceRate)/1000
        );
    }

    
    function changeTemplate(string memory tempName) public onlyOwner {
        (address tempAddr,) = ChanceRoomFactory.tempLatestVersion(tempName);
        AppStorage.layout().Address.tempAddr = tempAddr;
    }

    function purchaseTicket(uint256 tokenId) public payable {
        require(AppStorage.layout().Uint256.winnerId == 0, "ChanceRoom expired");
        require(msg.value >= AppStorage.layout().Uint256.ticketPrice, "insufficient fee");
        if(chainId() == 137) {
            if(LINK.balanceOf(address(this)) < linkFee){
                swap_MATIC_LINK677(linkFee, 10 ** 17);
            }
        }
        _safeMint(msg.sender, tokenId);
        AppStorage.layout().Uint256.soldTickets ++;
    }

    function trigger() public {
        require(
            block.timestamp >= AppStorage.layout().Uint256.deadLine, 
            "trigger time has not reached"
        );

        AppStorage.layout().Bool.triggered = true;

        if(chainId() == 137) {
            _getRandomNumber();
        } else {
            _select(block.timestamp);
        }

        emit Trigger(msg.sender);
    }

    function _select(uint256 randomness) internal override {

        uint256 denom = totalSupply();

        uint256 randIndex = randomness % denom + 1;

        address winner = ownerOf(randIndex);
        AppStorage.layout().Uint256.winnerId = randIndex;
        IERC721(AppStorage.layout().Address.nftAddr).safeTransferFrom(address(this), winner, AppStorage.layout().Uint256.nftId);
        payable(owner()).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}