// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingVaultERC721 is Ownable, IERC721Receiver {
    IERC721 public immutable nftContract;

    struct Stake {
        uint248 timestamp;
        address owner;
    }

    mapping(uint256 => Stake) public vault;
    mapping(address => uint256) public rewards;
    uint256 public constant REWARD_PER_DAY = 10 ether;

    constructor(address _nftContract) Ownable(msg.sender) {
        require(_nftContract != address(0), "Invalid NFT address");
        nftContract = IERC721(_nftContract);
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(msg.sender == address(nftContract), "Invalid NFT Contract");
        
        vault[tokenId] = Stake(uint248(block.timestamp), from);
        return IERC721Receiver.onERC721Received.selector;
    }

    function stake(uint256 tokenId) external {
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function calculateReward(uint256 tokenId) public view returns (uint256) {
        Stake memory staked = vault[tokenId];
        if (staked.owner == address(0)) return 0;
        
        uint256 timeStaked = block.timestamp - staked.timestamp;
        return (timeStaked * REWARD_PER_DAY) / 1 days;
    }

    function unstake(uint256 tokenId) external {
        Stake memory staked = vault[tokenId];
        
        // 1. CHECKS
        require(staked.owner == msg.sender, "Not the NFT owner");

        // 2. EFFECTS
        uint256 reward = calculateReward(tokenId);
        rewards[msg.sender] += reward;
        delete vault[tokenId]; // مسح الـ Stake من الـ Storage

        // 3. INTERACTIONS
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
