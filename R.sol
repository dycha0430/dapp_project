// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./IRoomShare.sol";

contract RoomShare is IRoomShare {
  // Rent[] _rents;
  // Room[] _rooms;
  uint256 roomId;
  mapping (uint256=>Room) rooms;
  uint256 rentId;
  // mapping (uint256=>Rent) rents;
  mapping (address=>Rent[]) rentsByUser;
  mapping (uint256=>Rent[]) rentsByRoomId;

  constructor() {
    roomId = 0;
    rentId = 0;
  }

  function getMyRents() external override view returns(Rent[] memory) {
    /* 함수를 호출한 유저의 대여 목록을 가져온다. */
    // Rent[] myRents;
    // for (uint i = 0; i < _rents.length; i++) {
    //   if (_rents[i].renter == msg.sender) {
    //     myRents.push(_rents[i]);
    //   }
    // }

    // return myRents;
    return rentsByUser[msg.sender];
  }

  function getRoomRentHistory(uint _roomId) external override view returns(Rent[] memory) {
    /* 특정 방의 대여 히스토리를 보여준다. */
    // Rent[] history;
    // for (uint i = 0; i < _rents.length; i++) {
    //   if (_rents[i].rId == roomId) {
    //     history.push(_rents[i]);
    //   }
    // }
    // return history;
    return rentsByRoomId[_roomId];
  }

  function shareRoom( string calldata name, 
                      string calldata location, 
                      uint price ) external override {
    /**
     * 1. isActive 초기값은 true로 활성화, 
     * 함수를 호출한 유저가 방의 소유자이며, 
     * 365 크기의 boolean 배열을 생성하여 방 객체를 만든다.
     * 2. 방의 id와 방 객체를 매핑한다.
     */
     bool[] memory isRented = new bool[](365);
     for (uint i = 0; i < 365; i++) {
       isRented[i] = false;
     }
     Room memory room = Room(roomId, name, location, true, price, msg.sender, isRented);
     rooms[roomId] = room;
    //  _rooms.push(room);
    emit NewRoom(roomId++);
  }

  function rentRoom(uint _roomId, uint checkInDate, uint checkOutDate) payable external override {
    /**
     * 1. roomId에 해당하는 방을 조회하여 아래와 같은 조건을 만족하는지 체크한다.
     *    a. 현재 활성화(isActive) 되어 있는지
     *    b. 체크인날짜와 체크아웃날짜 사이에 예약된 날이 있는지 
     *    c. 함수를 호출한 유저가 보낸 이더리움 값이 대여한 날에 맞게 지불되었는지(단위는 1 Finney, 10^15 Wei) 
     * 2. 방의 소유자에게 값을 지불하고 (msg.value 사용) createRent를 호출한다.
     */
     
     Room memory room = rooms[_roomId];
     if (!room.isActive) return;
     bool canRent = true;
     for (uint i = checkInDate; i <= checkOutDate; i++) {
       if (room.isRented[i]) {
         canRent = false;
         break;
       }
     }

     if (!canRent) return;
     
     // C!!!?!?!
    //  _sendFunds(room.owner, msg.value);
    _createRent(_roomId, checkInDate, checkOutDate);    
     
  }

  function _createRent(uint256 _roomId, uint256 checkInDate, uint256 checkoutDate) internal {
    /**
     * 1. 함수를 호출한 사용자 계정으로 대여 객체를 만들고, 변수 저장 공간에 유의하며 체크인날짜부터 체크아웃날짜에 해당하는 배열 인덱스를 체크한다(초기값은 false이다.).
     * 2. 계정과 대여 객체들을 매핑한다. (대여 목록)
     * 3. 방 id와 대여 객체들을 매핑한다. (대여 히스토리)
     */
     Rent memory rent = Rent(rentId, _roomId, checkInDate, checkoutDate, msg.sender);
     Room memory room = rooms[_roomId];
     for (uint i = checkInDate; i <= checkoutDate; i++) {
       require(room.isRented[i] == false, "ERROR: room is already rented.");
       room.isRented[i] = true;
     }
     
     rentsByUser[msg.sender].push(rent);
     rentsByRoomId[_roomId].push(rent);

    emit NewRent(_roomId, rentId++);
  }

  function _sendFunds (address owner, uint256 value) internal {
      payable(owner).transfer(value);
  }
  

  function recommendDate(uint _roomId, uint checkInDate, uint checkOutDate) external override view returns(uint[2] memory) {
    /**
     * 대여가 이미 진행되어 해당 날짜에 대여가 불가능 할 경우, 
     * 기존에 예약된 날짜가 언제부터 언제까지인지 반환한다.
     * checkInDate(체크인하려는 날짜) <= 대여된 체크인 날짜 , 대여된 체크아웃 날짜 < checkOutDate(체크아웃하려는 날짜)
     */

     uint[2] memory ret;
     ret[0] = 1;
     ret[1] = 2;
     return ret;
  }

  // ...

}