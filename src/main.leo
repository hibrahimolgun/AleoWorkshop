// The 'chorsterworkshopankara' program.
program chorsterworkshopankara.aleo {
    
    mapping account:address => u64;

    record patates {
        owner: address,
        amount: u64,
    }

    transition mint_public(public receiver:address, public amount:u64) {
        return then finalize(receiver,amount);
    }

    finalize mint_public(public receiver:address, public amount:u64) {
        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition mint_private(receiver:address, amount:u64) -> patates 
    {
        return patates{
            owner: receiver,
            amount: amount
        };
    }

    transition transfer_public(public receiver:address, public amount:u64)
    {
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender:address, public receiver:address, public amount:u64)
    {
        let sender_amount:u64 = Mapping::get_or_use(account,sender ,0u64);
        Mapping::set(account, sender, sender_amount - amount);

        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_private(sender:patates, receiver:address, amount:u64) -> (patates, patates)
    {
        let difference:u64 = sender.amount - amount;

        let remaining:patates = patates{
            owner:sender.owner,
            amount:difference
        };

        let transferred:patates = patates{
            owner:receiver,
            amount:amount
        };

        return (remaining, transferred);
    }

    transition transfer_private_to_public(sender:patates, public receiver:address, public amount:u64) -> patates
    {
        let difference:u64 = sender.amount - amount;

        let remaining:patates = patates{
            owner:sender.owner,
            amount:difference
        };

        return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver:address, public amount:u64)
    {
        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_public_to_private(receiver:address, amount:u64) -> patates
    {
        let transferred:patates = patates{
            owner:receiver,
            amount:amount
        };

        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender:address, public amount:u64)
    {
        let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }
}
