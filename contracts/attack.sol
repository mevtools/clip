def unknown00007046(): # not payable
  if 0x4bad9f1a15bd17e78b59e086aa4092a3ce0de5c2 != caller:
      if 0xd966d085127a3bfa686afa4ee0c52dbe4e962ef4 != caller:
          if 0x71e5581ea04d93336fd6d2557c56f5c6ab2bea8 != caller:
              if 0x90f729f31e20c58b93a7092f1e10bdae9cc4d82b != caller:
                  if 0xd794ad6fe0cdfcb15597da157077e6d245479f4a != caller:
                      if 0xb48b978ab606fb6065097a7403e47e58ca464462 != caller:
                          if 0xac1afe8faad8b5a75bd0f7fedeec0e798675ee49 != caller:
                              if 0xc577ccd813957558ea7eca6f14ba9b90c58377c0 != caller:
                                  if 0x60befe4438001c95ec75d09aedfac0dd4c10820b != caller:
                                      revert with 0, 'O'
  static call mem[0 len 12], call.data[32 len 20].getReserves() with:
          gas 5000 wei
  if bool(call.data[52 len 1]) == 1:
      if (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]) >= mem[0 len 18], call.data[18 len 14]:
          call 0x55d398326f99059ff775485246999027b3197955.transfer(address to, uint256 tokens) with:               gas gas_remaining wei
              args mem[0 len 12], call.data[32 len 20], mem[0 len 18], call.data[4 len 14]
          if bool(call.data[52 len 1]) == 1 == 1:
              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                   gas gas_remaining wei
                  args 0, (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]), this.address, 128, 0
          else:
              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                   gas gas_remaining wei
                  args (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]), 0, this.address, 128, 0
          require ext_call.success
      else:
          if calldata.size <= 53:
              call mem[0 len 12], call.data[52 len 20] with:
                   gas gas_remaining wei
          else:
              static call mem[0 len 12], call.data[73 len 20].balanceOf(address tokenOwner) with:
                      gas 5000 wei
                     args mem[0 len 12], call.data[53 len 20]
              if ext_call.return_data[0] - 1 >= mem[0 len 18], call.data[18 len 14] / 500:
                  if ext_call.return_data[0] - 1 <= mem[0 len 18], call.data[18 len 14]:
                      call mem[0 len 12], call.data[53 len 20].0xe2da3653 with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[73 len 20], ext_call.return_data[0] - 1
                      call mem[0 len 12], call.data[73 len 20].transfer(address to, uint256 tokens) with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[32 len 20], ext_call.return_data[0] - 1
                      if bool(call.data[52 len 1]) != 1:
                          if bool(call.data[52 len 1]) == 1 != 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args 0, (10000 * ext_call.return_data[0] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), this.address, 128, 0
                          else:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * ext_call.return_data[0] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                      else:
                          if bool(call.data[52 len 1]) == 1 == 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * ext_call.return_data[0] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                          else:
                              if mem[32 len 31], call.data[52 len 1] == 1:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args 0, (10000 * ext_call.return_data[0] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), this.address, 128, 0
                              else:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args (10000 * ext_call.return_data[0] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                  else:
                      call mem[0 len 12], call.data[53 len 20].0xe2da3653 with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[73 len 20], mem[0 len 18], call.data[18 len 14]
                      call mem[0 len 12], call.data[73 len 20].transfer(address to, uint256 tokens) with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[32 len 20], mem[0 len 18], call.data[18 len 14]
                      if bool(call.data[52 len 1]) != 1:
                          if bool(call.data[52 len 1]) == 1 != 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args 0, (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), this.address, 128, 0
                          else:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                      else:
                          if bool(call.data[52 len 1]) == 1 == 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                          else:
                              if mem[32 len 31], call.data[52 len 1] == 1:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args 0, (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), this.address, 128, 0
                              else:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                  require ext_call.success
  else:
      if (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]) >= mem[0 len 18], call.data[18 len 14]:
          call 0x55d398326f99059ff775485246999027b3197955.transfer(address to, uint256 tokens) with:               gas gas_remaining wei
              args mem[0 len 12], call.data[32 len 20], mem[0 len 18], call.data[4 len 14]
          if bool(call.data[52 len 1]) == 1 == 1:
              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                   gas gas_remaining wei
                  args 0, (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]), this.address, 128, 0
          else:
              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                   gas gas_remaining wei
                  args (10000 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14] * ext_call.return_data[0]) / (10000 * ext_call.return_data[32]) + (10000 * mem[0 len 18], call.data[4 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[4 len 14]), 0, this.address, 128, 0
          require ext_call.success
      else:
          if calldata.size <= 53:
              call mem[0 len 12], call.data[52 len 20] with:
                   gas gas_remaining wei
          else:
              static call mem[0 len 12], call.data[73 len 20].balanceOf(address tokenOwner) with:
                      gas 5000 wei
                     args mem[0 len 12], call.data[53 len 20]
              if ext_call.return_data[0] - 1 >= mem[0 len 18], call.data[18 len 14] / 500:
                  if ext_call.return_data[0] - 1 <= mem[0 len 18], call.data[18 len 14]:
                      call mem[0 len 12], call.data[53 len 20].0xe2da3653 with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[73 len 20], ext_call.return_data[0] - 1
                      call mem[0 len 12], call.data[73 len 20].transfer(address to, uint256 tokens) with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[32 len 20], ext_call.return_data[0] - 1
                      if bool(call.data[52 len 1]) != 1:
                          if bool(call.data[52 len 1]) == 1 != 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args 0, (10000 * ext_call.return_data[0] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[32]) / (20000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), this.address, 128, 0
                          else:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * ext_call.return_data[0] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[32]) / (20000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                      else:
                          if bool(call.data[52 len 1]) == 1 == 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * ext_call.return_data[0] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[32]) / (20000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                          else:
                              if mem[32 len 31], call.data[52 len 1] == 1:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args 0, (10000 * ext_call.return_data[0] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[32]) / (20000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), this.address, 128, 0
                              else:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args (10000 * ext_call.return_data[0] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0] * ext_call.return_data[32]) / (20000 * ext_call.return_data[0]) - (mem[32 len 31], call.data[52 len 1] / 2 * ext_call.return_data[0]), 0, this.address, 128, 0
                  else:
                      call mem[0 len 12], call.data[53 len 20].0xe2da3653 with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[73 len 20], mem[0 len 18], call.data[18 len 14]
                      call mem[0 len 12], call.data[73 len 20].transfer(address to, uint256 tokens) with:
                           gas gas_remaining wei
                          args mem[0 len 12], call.data[32 len 20], mem[0 len 18], call.data[18 len 14]
                      if bool(call.data[52 len 1]) != 1:
                          if bool(call.data[52 len 1]) == 1 != 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args 0, (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), this.address, 128, 0
                          else:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                      else:
                          if bool(call.data[52 len 1]) == 1 == 1:
                              call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                   gas gas_remaining wei
                                  args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                          else:
                              if mem[32 len 31], call.data[52 len 1] == 1:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args 0, (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), this.address, 128, 0
                              else:
                                  call mem[0 len 12], call.data[32 len 20].0x22c0d9f with:
                                       gas gas_remaining wei
                                      args (10000 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14] * ext_call.return_data[32]) / (10000 * ext_call.return_data[0]) + (10000 * mem[0 len 18], call.data[18 len 14]) - (mem[32 len 31], call.data[52 len 1] / 2 * mem[0 len 18], call.data[18 len 14]), 0, this.address, 128, 0
                  require ext_call.success